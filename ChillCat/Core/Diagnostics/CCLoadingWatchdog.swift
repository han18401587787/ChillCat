import Foundation

/// 加载状态看门狗 — 检测 isLoading 等标志是否超时未复位
/// 用于发现"按钮永久禁用"类 Bug
@MainActor
final class CCLoadingWatchdog {
    static let shared = CCLoadingWatchdog()

    /// 加载超时阈值（秒）
    private let timeoutThreshold: TimeInterval = 30.0

    /// 正在监控的任务
    private var monitoredTasks: [UUID: (startTime: Date, label: String)] = [:]
    private var timer: Timer?

    private init() {
        #if DEBUG
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkTimeouts()
            }
        }
        #endif
    }

    /// 开始监控一个加载操作
    func startWatching(label: String) -> UUID {
        let id = UUID()
        monitoredTasks[id] = (startTime: Date(), label: label)
        return id
    }

    /// 停止监控（加载完成）
    func stopWatching(_ id: UUID) {
        monitoredTasks.removeValue(forKey: id)
    }

    /// 检查超时
    private func checkTimeouts() {
        let now = Date()
        var timedOutLabels: [String] = []

        for (id, task) in monitoredTasks {
            let elapsed = now.timeIntervalSince(task.startTime)
            if elapsed > timeoutThreshold {
                timedOutLabels.append("\(task.label) (已持续 \(Int(elapsed))s)")
                monitoredTasks.removeValue(forKey: id)
            }
        }

        for label in timedOutLabels {
            LogW("⚠️ 加载状态超时未复位: \(label)", module: .ui, category: "Watchdog")
        }
    }
}
