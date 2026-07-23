import Foundation
import SwiftUI

/// 诊断事件条目 — 供诊断面板展示
struct CCDiagnosticEvent: Identifiable, Sendable {
    let id: UUID
    let timestamp: Date
    let level: CCDiagnosticLevel
    let module: String
    let category: String
    let message: String
    let file: String
    let line: Int
    let errorDescription: String?
    let traceID: String?

    enum CCDiagnosticLevel: String, Sendable, Comparable {
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"

        static func < (lhs: CCDiagnosticLevel, rhs: CCDiagnosticLevel) -> Bool {
            let order: [CCDiagnosticLevel] = [.warning, .error, .fatal]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }

        var color: Color {
            switch self {
            case .warning: return .orange
            case .error: return .red
            case .fatal: return .purple
            }
        }

        var icon: String {
            switch self {
            case .warning: return "⚠️"
            case .error: return "🔴"
            case .fatal: return "💀"
            }
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

// MARK: - 诊断数据收集器

/// 全局诊断数据收集器 — 收集 LogE/LogW 级别日志和 CCErrorReporter 上报的错误
/// 仅在 #if DEBUG 下激活，Release 编译自动剔除
final class CCDiagnosticCollector: ObservableObject {
    static let shared = CCDiagnosticCollector()

    /// 诊断事件列表（按时间倒序）
    @Published private(set) var events: [CCDiagnosticEvent] = []

    /// 当前页面名称（由各 View 在 onAppear 中设置）
    @Published var currentPage: String = "Unknown"

    /// 最大保留事件数
    private let maxEvents = 200

    /// 错误计数
    @Published private(set) var errorCount: Int = 0
    @Published private(set) var warningCount: Int = 0

    // MARK: - 自动上报新错误到 GitHub（仅 DEBUG）

    #if DEBUG
    private let autoUploadLock = NSLock()
    private var seenSignatures: Set<String> = []
    private var autoUploadCount = 0
    private let maxAutoUploads = 30
    private let seenSignaturesKey = "cc_debug_seen_error_signatures"
    private let autoUploadEnabledKey = "cc_debug_auto_upload"

    /// 默认开启；可在 UserDefaults 设 cc_debug_auto_upload = false 关闭
    private var autoUploadEnabled: Bool {
        guard UserDefaults.standard.object(forKey: autoUploadEnabledKey) != nil else { return true }
        return UserDefaults.standard.bool(forKey: autoUploadEnabledKey)
    }
    #endif

    private init() {
        #if DEBUG
        if let saved = UserDefaults.standard.array(forKey: seenSignaturesKey) as? [String] {
            seenSignatures = Set(saved)
        }
        #endif
    }

    // MARK: - 记录事件

    func record(
        level: CCDiagnosticEvent.CCDiagnosticLevel,
        message: String,
        module: String = "Default",
        category: String = "General",
        file: String = #file,
        line: Int = #line,
        errorDescription: String? = nil,
        traceID: String? = nil
    ) {
        let event = CCDiagnosticEvent(
            id: UUID(),
            timestamp: Date(),
            level: level,
            module: module,
            category: category,
            message: message,
            file: (file as NSString).lastPathComponent,
            line: line,
            errorDescription: errorDescription,
            traceID: traceID
        )
        events.insert(event, at: 0)

        switch level {
        case .warning: warningCount += 1
        case .error, .fatal: errorCount += 1
        }

        // 限制事件数量
        if events.count > maxEvents {
            events.removeLast(events.count - maxEvents)
        }

        // 自动上报新错误到 GitHub Issue（仅 DEBUG，需配置 Token + 跨启动去重）
        #if DEBUG
        if level == .error || level == .fatal {
            let signature = "\(module)|\(message)"
            autoUploadLock.lock()
            let alreadySeen = seenSignatures.contains(signature)
            autoUploadLock.unlock()
            if !alreadySeen {
                Task { await self.autoUploadIfAllowed(signature: signature, event: event) }
            }
        }
        #endif
    }

    /// 从 CCLogEntry 记录（供 CCLogger 桥接）
    func record(from entry: CCLogEntry) {
        guard let level = CCDiagnosticEvent.CCDiagnosticLevel(rawValue: entry.level) else { return }
        record(
            level: level,
            message: entry.message,
            module: entry.module,
            category: entry.category,
            file: entry.file,
            line: entry.line,
            errorDescription: entry.error?.description,
            traceID: entry.traceID
        )
    }

    // MARK: - 自动上报（DEBUG）

    #if DEBUG
    /// 仅当开启、已配置 Token、且本次会话未超限时才上报，并标记该错误已见（跨启动持久化去重）
    @MainActor
    private func autoUploadIfAllowed(signature: String, event: CCDiagnosticEvent) async {
        guard autoUploadEnabled, CCGitHubIssueReporter.shared.hasToken else { return }

        autoUploadLock.lock()
        let canUpload = autoUploadCount < maxAutoUploads
        if canUpload {
            seenSignatures.insert(signature)
            autoUploadCount += 1
            let snapshot = Array(seenSignatures.suffix(1000))
            autoUploadLock.unlock()
            UserDefaults.standard.set(snapshot, forKey: seenSignaturesKey)
        } else {
            autoUploadLock.unlock()
        }
        guard canUpload else { return }

        let title = autoIssueTitle(event)
        let body = autoIssueBody(event)
        _ = await CCGitHubIssueReporter.shared.submitWithQueue(
            title: title,
            body: body,
            screenshot: nil,
            labels: ["bug", "from-debug-panel", "auto-error"]
        )
    }

    private func autoIssueTitle(_ e: CCDiagnosticEvent) -> String {
        let desc = String(e.message.prefix(80))
        return "[Bug] \(currentPage): \(desc)"
    }

    private func autoIssueBody(_ e: CCDiagnosticEvent) -> String {
        var lines: [String] = [
            "## 自动上报的错误（Debug 诊断采集器）",
            "",
            "| 字段 | 内容 |",
            "|------|------|",
            "| **页面** | \(currentPage) |",
            "| **级别** | \(e.level.rawValue) |",
            "| **模块** | \(e.module) |",
            "| **时间** | \(ISO8601DateFormatter().string(from: e.timestamp)) |",
            "",
            "### 错误信息",
            e.message,
            "",
        ]
        if let err = e.errorDescription {
            lines.append("### 错误详情")
            lines.append(err)
            lines.append("")
        }
        lines.append("### 代码位置")
        lines.append("`\(e.file):\(e.line)`")
        lines.append("")
        lines.append("### 近期诊断日志")
        lines.append("```")
        for ev in recentEvents(count: 10) {
            lines.append("[\(ev.formattedTime)] [\(ev.level.rawValue)] [\(ev.module)] \(ev.message)")
        }
        lines.append("```")
        return lines.joined(separator: "\n")
    }
    #endif

    // MARK: - 导出

    /// 导出所有事件为可读文本
    func exportLog() -> String {
        let formatter = ISO8601DateFormatter()
        var lines: [String] = [
            "=== ChillCat 诊断日志 ===",
            "导出时间: \(formatter.string(from: Date()))",
            "错误: \(errorCount) | 警告: \(warningCount) | 总计: \(events.count)",
            "当前页面: \(currentPage)",
            "",
            "--- 事件列表（最新在前）---",
        ]

        for event in events {
            lines.append("[\(event.formattedTime)] [\(event.level.rawValue)] [\(event.module)/\(event.category)] \(event.message)")
            if let err = event.errorDescription {
                lines.append("  └─ Error: \(err)")
            }
            lines.append("     @ \(event.file):\(event.line)")
        }

        return lines.joined(separator: "\n")
    }

    /// 导出最近 N 条事件（用于 Bug 标记）
    func recentEvents(count: Int = 20) -> [CCDiagnosticEvent] {
        return Array(events.prefix(count))
    }

    // MARK: - 清理

    func clear() {
        events.removeAll()
        errorCount = 0
        warningCount = 0
    }
}
