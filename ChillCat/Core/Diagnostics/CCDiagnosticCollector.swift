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
            guard let lhsIndex = order.firstIndex(of: lhs),
                  let rhsIndex = order.firstIndex(of: rhs) else {
                return false
            }
            return lhsIndex < rhsIndex
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

    private init() {}

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
