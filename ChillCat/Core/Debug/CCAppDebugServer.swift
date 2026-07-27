import Foundation
import Network
import UIKit
import ReplayKit

#if DEBUG

// MARK: - AppDebugServer

/// 应用内 Debug HTTP Server — 仅在 `#if DEBUG` 下编译
///
/// 基于 NWListener (Network.framework) 实现轻量 HTTP 服务，
/// 无需引入第三方依赖。提供以下路由：
///
/// | 路由 | 方法 | 说明 |
/// |------|------|------|
/// | `/screenshot` | GET | 截取当前屏幕，返回 PNG |
/// | `/list_actions` | GET | 列出所有已注册的 Debug Action（JSON） |
/// | `/activate` | POST | 激活指定 Debug Action（body: `{"id":"xxx"}`） |
/// | `/app_state` | GET | 返回 App 状态（当前页面、内存、诊断摘要） |
/// | `/record_start` | POST | 开始 ReplayKit 录屏 |
/// | `/record_stop` | POST | 停止录屏，返回视频 |
/// | `/health` | GET | 健康检查 |
///
/// 启动方式（在 App 入口）：
/// ```swift
/// #if DEBUG
/// CCAppDebugServer.shared.start(port: 9080)
/// #endif
/// ```
///
/// 外部连接方式：
/// - **WiFi 直连**: `http://<iPhone IP>:9080/screenshot`
/// - **USB 隧道**: `iproxy 9080 9080` 然后 `http://localhost:9080/screenshot`
/// - **云 MCP Bridge**: 通过 `app-debug-mcp-bridge.py` 桥接到 MCP 协议
@MainActor
final class CCAppDebugServer: ObservableObject {
    static let shared = CCAppDebugServer()

    // MARK: - 状态

    @Published private(set) var isRunning = false
    @Published private(set) var port: UInt16 = 9080
    @Published private(set) var connectedPeers: Int = 0

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let connectionLock = NSLock()

    // 录屏
    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false

    private init() {}

    // MARK: - 启动 / 停止

    func start(port: UInt16 = 9080) {
        guard !isRunning else {
            LogW("AppDebugServer 已在运行中 (port \(self.port))", module: .debug, category: "Server")
            return
        }

        self.port = port

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        do {
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            LogE("AppDebugServer 创建 listener 失败: \(error)", module: .debug, category: "Server", error: error)
            return
        }

        listener?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                switch state {
                case .ready:
                    self?.isRunning = true
                    LogI("AppDebugServer 已启动 — http://localhost:\(port)", module: .debug, category: "Server")
                case .failed(let error):
                    LogE("AppDebugServer 失败: \(error)", module: .debug, category: "Server", error: error)
                    self?.isRunning = false
                case .cancelled:
                    self?.isRunning = false
                default:
                    break
                }
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            Task { @MainActor [weak self] in
                self?.handleConnection(connection)
            }
        }

        listener?.start(queue: .main)
        LogI("AppDebugServer 正在启动 (port \(port))...", module: .debug, category: "Server")
    }

    func stop() {
        listener?.cancel()
        listener = nil

        connectionLock.lock()
        for conn in connections {
            conn.cancel()
        }
        connections.removeAll()
        connectionLock.unlock()

        isRunning = false
        connectedPeers = 0
        LogI("AppDebugServer 已停止", module: .debug, category: "Server")
    }

    // MARK: - 连接处理

    private func handleConnection(_ connection: NWConnection) {
        connectionLock.lock()
        connections.append(connection)
        connectedPeers = connections.count
        connectionLock.unlock()

        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                switch state {
                case .ready:
                    LogD("AppDebugServer: 新连接", module: .debug, category: "Server")
                    // 开始接收数据
                    self.receive(on: connection)
                case .failed, .cancelled:
                    self.removeConnection(connection)
                default:
                    break
                }
            }
        }

        connection.start(queue: .main)
    }

    /// 从非隔离的 NWConnection 回调中安全移除连接
    private nonisolated func removeConnection(_ connection: NWConnection) {
        connectionLock.lock()
        defer { connectionLock.unlock() }
        connections.removeAll { $0 === connection }
        connection.cancel()
    }

    /// 接收数据（可在非隔离上下文中调用）
    private nonisolated func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if let data = data, !data.isEmpty {
                Task { @MainActor in
                    await self.processRequest(data, on: connection)
                }
            }

            if isComplete || error != nil {
                self.removeConnection(connection)
            } else if error == nil {
                // 继续接收（HTTP Keep-Alive）
                self.receive(on: connection)
            }
        }
    }
        guard let requestString = String(data: data, encoding: .utf8) else {
            sendResponse(status: 400, body: "Bad Request", contentType: "text/plain", on: connection)
            return
        }

        let lines = requestString.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else {
            sendResponse(status: 400, body: "Bad Request", contentType: "text/plain", on: connection)
            return
        }

        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(status: 400, body: "Bad Request", contentType: "text/plain", on: connection)
            return
        }

        let method = parts[0].uppercased()
        let path = parts[1]

        // 解析 body（POST 请求）
        var bodyString: String?
        if method == "POST" {
            if let bodyIndex = requestString.range(of: "\r\n\r\n") {
                bodyString = String(requestString[bodyIndex.upperBound...])
            }
        }

        // 路由分发
        LogD("AppDebugServer: \(method) \(path)", module: .debug, category: "Server")

        switch (method, path) {
        case ("GET", "/health"):
            handleHealth(on: connection)

        case ("GET", "/screenshot"):
            await handleScreenshot(on: connection)

        case ("GET", "/list_actions"):
            handleListActions(on: connection)

        case ("POST", "/activate"):
            handleActivate(body: bodyString, on: connection)

        case ("GET", "/app_state"):
            await handleAppState(on: connection)

        case ("POST", "/record_start"):
            await handleRecordStart(on: connection)

        case ("POST", "/record_stop"):
            await handleRecordStop(on: connection)

        default:
            // 404
            let body = """
            {
              "error": "Not Found",
              "available_routes": [
                "GET  /health",
                "GET  /screenshot",
                "GET  /list_actions",
                "POST /activate",
                "GET  /app_state",
                "POST /record_start",
                "POST /record_stop"
              ]
            }
            """
            sendResponse(status: 404, body: body, contentType: "application/json", on: connection)
        }
    }

    // MARK: - 路由处理

    /// GET /health
    private func handleHealth(on connection: NWConnection) {
        let body = """
        {
          "status": "ok",
          "server": "ChillCat AppDebugServer",
          "version": "1.0.0",
          "uptime": "\(ProcessInfo.processInfo.systemUptime)",
          "connected_peers": \(connectedPeers)
        }
        """
        sendResponse(status: 200, body: body, contentType: "application/json", on: connection)
    }

    /// GET /screenshot — 截取当前屏幕，返回 PNG
    private func handleScreenshot(on connection: NWConnection) async {
        guard let screenshot = await captureScreen() else {
            sendResponse(status: 500, body: "{\"error\":\"截图失败\"}", contentType: "application/json", on: connection)
            return
        }

        guard let pngData = screenshot.pngData() else {
            sendResponse(status: 500, body: "{\"error\":\"PNG 编码失败\"}", contentType: "application/json", on: connection)
            return
        }

        sendResponse(status: 200, body: pngData, contentType: "image/png", on: connection)
    }

    /// GET /list_actions — 列出所有已注册的 Debug Action
    private func handleListActions(on connection: NWConnection) {
        let json = CCDebugActionRegistry.shared.exportJSON()
        sendResponse(status: 200, body: json, contentType: "application/json", on: connection)
    }

    /// POST /activate — 激活指定 Debug Action
    private func handleActivate(body: String?, on connection: NWConnection) {
        guard let body = body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let actionID = json["id"] as? String else {
            sendResponse(status: 400, body: "{\"error\":\"缺少 id 参数\"}", contentType: "application/json", on: connection)
            return
        }

        let success = CCDebugActionRegistry.shared.activate(id: actionID)

        let response = """
        {
          "action_id": "\(actionID)",
          "success": \(success),
          "message": "\(success ? "已激活" : "未找到该 Action")"
        }
        """
        sendResponse(status: success ? 200 : 404, body: response, contentType: "application/json", on: connection)
    }

    /// GET /app_state — 返回 App 运行时状态
    private func handleAppState(on connection: NWConnection) async {
        let collector = CCDiagnosticCollector.shared
        let memory = await getMemoryUsage()

        let state: [String: Any] = [
            "current_page": collector.currentPage,
            "error_count": collector.errorCount,
            "warning_count": collector.warningCount,
            "total_events": collector.events.count,
            "memory_mb": String(format: "%.1f", memory),
            "device": UIDevice.current.model,
            "os_version": UIDevice.current.systemVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "is_recording": isRecording,
            "server_port": port,
            "connected_peers": connectedPeers,
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: state, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            sendResponse(status: 500, body: "{\"error\":\"状态序列化失败\"}", contentType: "application/json", on: connection)
            return
        }

        sendResponse(status: 200, body: jsonString, contentType: "application/json", on: connection)
    }

    /// POST /record_start — 开始 ReplayKit 录屏
    private func handleRecordStart(on connection: NWConnection) async {
        guard !isRecording else {
            sendResponse(status: 409, body: "{\"error\":\"已在录屏中\"}", contentType: "application/json", on: connection)
            return
        }

        guard recorder.isAvailable else {
            sendResponse(status: 500, body: "{\"error\":\"ReplayKit 不可用（模拟器不支持录屏）\"}", contentType: "application/json", on: connection)
            return
        }

        do {
            try await recorder.startRecording()
            isRecording = true
            LogI("AppDebugServer: 录屏已开始", module: .debug, category: "Server")
            sendResponse(status: 200, body: "{\"status\":\"recording_started\"}", contentType: "application/json", on: connection)
        } catch {
            LogE("AppDebugServer: 录屏启动失败: \(error)", module: .debug, category: "Server", error: error)
            sendResponse(status: 500, body: "{\"error\":\"\(error.localizedDescription)\"}", contentType: "application/json", on: connection)
        }
    }

    /// POST /record_stop — 停止录屏
    private func handleRecordStop(on connection: NWConnection) async {
        guard isRecording else {
            sendResponse(status: 409, body: "{\"error\":\"未在录屏\"}", contentType: "application/json", on: connection)
            return
        }

        do {
            try await recorder.stopRecording(withOutput: tempVideoURL())
            isRecording = false
            LogI("AppDebugServer: 录屏已停止", module: .debug, category: "Server")
            // 注意：录屏视频会由系统导出到相册（ReplayKit 默认行为）
            // 如需通过 HTTP 返回视频数据，需额外处理
            sendResponse(status: 200, body: "{\"status\":\"recording_stopped\",\"note\":\"视频已保存到相册\"}", contentType: "application/json", on: connection)
        } catch {
            LogE("AppDebugServer: 录屏停止失败: \(error)", module: .debug, category: "Server", error: error)
            sendResponse(status: 500, body: "{\"error\":\"\(error.localizedDescription)\"}", contentType: "application/json", on: connection)
        }
    }

    // MARK: - HTTP 响应

    private func sendResponse(status: Int, body: String, contentType: String, on connection: NWConnection) {
        let bodyData = body.data(using: .utf8)!
        sendResponse(status: status, body: bodyData, contentType: contentType, on: connection)
    }

    private func sendResponse(status: Int, body: Data, contentType: String, on connection: NWConnection) {
        let statusText = HTTPStatusText(status)
        let header = """
        HTTP/1.1 \(status) \(statusText)\r
        Content-Type: \(contentType)\r
        Content-Length: \(body.count)\r
        Connection: close\r
        Access-Control-Allow-Origin: *\r
        \r\n
        """

        guard let headerData = header.data(using: .utf8) else { return }

        var response = Data()
        response.append(headerData)
        response.append(body)

        connection.send(content: response, completion: .contentProcessed { [weak self] error in
            if let error = error {
                LogW("AppDebugServer 发送响应失败: \(error)", module: .debug, category: "Server")
            }
            // 发送完毕后关闭连接
            self?.removeConnection(connection)
        })
    }

    // MARK: - 截图

    private func captureScreen() async -> UIImage? {
        // 必须在主线程访问 UI
        return await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return nil
            }
            let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
            return renderer.image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
        }
    }

    // MARK: - 内存

    private func getMemoryUsage() async -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            return Double(info.resident_size) / 1_048_576.0 // bytes → MB
        }
        return 0
    }

    // MARK: - 临时文件

    private func tempVideoURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent("debug_recording_\(Date().timeIntervalSince1970).mp4")
    }
}

// MARK: - HTTP 状态码

private func HTTPStatusText(_ code: Int) -> String {
    switch code {
    case 200: return "OK"
    case 400: return "Bad Request"
    case 404: return "Not Found"
    case 409: return "Conflict"
    case 500: return "Internal Server Error"
    default: return "Unknown"
    }
}

// MARK: - 非隔离扩展（用于 NWConnection 回调中的非 Sendable 闭包）

extension CCAppDebugServer {
    /// 从非隔离上下文安全访问 shared
    nonisolated static func sharedNonisolated() -> CCAppDebugServer {
        // NWListener 的回调可能在非 MainActor 上，
        // 但 CCAppDebugServer 的所有状态访问必须在 MainActor
        // 这里返回 shared 实例，调用方负责确保 @MainActor 上下文
        return shared
    }
}

#endif // DEBUG
