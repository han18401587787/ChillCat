import SwiftUI

/// Debug 诊断面板 — 摇晃手机弹出
/// 展示运行时错误、警告、网络状态，支持一键 Bug 标记和日志导出
struct CCDiagnosticPanelView: View {
    @ObservedObject private var collector = CCDiagnosticCollector.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showExportSheet = false
    @State private var exportedText: String = ""
    @State private var showBugDraft = false
    @State private var bugDescription: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部统计栏
                statsBar

                // Tab 切换
                Picker("视图", selection: $selectedTab) {
                    Text("错误 (\(collector.errorCount))").tag(0)
                    Text("警告 (\(collector.warningCount))").tag(1)
                    Text("全部 (\(collector.events.count))").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // 事件列表
                if filteredEvents.isEmpty {
                    emptyView
                } else {
                    eventsList
                }
            }
            .navigationTitle("诊断面板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { collector.clear() }) {
                        Text("清空")
                            .font(.caption)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { markBug() }) {
                            Label("标记", systemImage: "ladybug")
                                .font(.caption)
                        }
                        Button(action: { exportLog() }) {
                            Label("导出", systemImage: "square.and.arrow.up")
                                .font(.caption)
                        }
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(text: exportedText)
        }
        .sheet(isPresented: $showBugDraft) {
            BugDraftView(
                pageName: collector.currentPage,
                recentEvents: collector.recentEvents(count: 20),
                onDismiss: { showBugDraft = false }
            )
        }
    }

    // MARK: - 统计栏

    private var statsBar: some View {
        HStack(spacing: 20) {
            StatBadge(count: collector.errorCount, label: "错误", color: .red)
            StatBadge(count: collector.warningCount, label: "警告", color: .orange)
            StatBadge(count: collector.events.count, label: "总计", color: .secondary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("当前页面")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(collector.currentPage)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private struct StatBadge: View {
        let count: Int
        let label: String
        let color: Color

        var body: some View {
            VStack(spacing: 2) {
                Text("\(count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(count > 0 ? color : .secondary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 筛选

    private var filteredEvents: [CCDiagnosticEvent] {
        switch selectedTab {
        case 0: return collector.events.filter { $0.level == .error || $0.level == .fatal }
        case 1: return collector.events.filter { $0.level == .warning }
        default: return collector.events
        }
    }

    // MARK: - 空状态

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.shield")
                .font(.system(size: 48))
                .foregroundColor(.green.opacity(0.6))
            Text("暂无诊断事件")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("使用 App 过程中出现的错误和警告\n会自动显示在这里")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - 事件列表

    private var eventsList: some View {
        List {
            ForEach(filteredEvents) { event in
                EventRow(event: event)
            }
        }
        .listStyle(.plain)
    }

    private struct EventRow: View {
        let event: CCDiagnosticEvent

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(event.level.icon)
                    Text(event.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("[\(event.module)]")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(.systemGray5))
                        .cornerRadius(3)
                }

                Text(event.message)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(3)

                if let err = event.errorDescription {
                    Text(err)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(2)
                }

                Text("@ \(event.file):\(event.line)")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - 导出

    private func exportLog() {
        exportedText = collector.exportLog()
        showExportSheet = true
    }

    // MARK: - Bug 标记

    private func markBug() {
        showBugDraft = true
    }
}

// MARK: - 导出 Sheet

private struct ExportSheet: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("诊断日志")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Bug 草稿

private struct BugDraftView: View {
    let pageName: String
    let recentEvents: [CCDiagnosticEvent]
    let onDismiss: () -> Void

    @State private var description: String = ""
    @State private var expectedResult: String = ""
    @State private var actualResult: String = ""

    private var bugReport: String {
        var lines = [
            "=== Bug 报告 ===",
            "页面: \(pageName)",
            "时间: \(ISO8601DateFormatter().string(from: Date()))",
            "",
            "【问题描述】",
            description.isEmpty ? "(待补充)" : description,
            "",
            "【期望结果】",
            expectedResult.isEmpty ? "(待补充)" : expectedResult,
            "",
            "【实际结果】",
            actualResult.isEmpty ? "(待补充)" : actualResult,
            "",
            "【最近诊断日志】",
        ]

        for event in recentEvents {
            lines.append("[\(event.formattedTime)] [\(event.level.rawValue)] [\(event.module)] \(event.message)")
            if let err = event.errorDescription {
                lines.append("  └─ \(err)")
            }
        }

        return lines.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("问题描述") {
                    TextField("描述你遇到的问题...", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("期望结果") {
                    TextField("正常情况下应该...", text: $expectedResult, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("实际结果") {
                    TextField("实际发生了什么...", text: $actualResult, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("自动附加信息") {
                    LabeledContent("页面", value: pageName)
                    LabeledContent("诊断事件", value: "\(recentEvents.count) 条")
                    if recentEvents.contains(where: { $0.level == .error }) {
                        Label("包含错误事件", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button(action: {
                        UIPasteboard.general.string = bugReport
                    }) {
                        Label("复制 Bug 报告", systemImage: "doc.on.doc")
                    }
                }
            }
            .navigationTitle("Bug 草稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { onDismiss() }
                }
            }
        }
    }
}

// MARK: - 摇晃手势扩展

extension UIDevice {
    /// 摇晃手势通知名称
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// MARK: - 摇晃弹出 Modifier

struct ShakePresentDiagnosticPanel: ViewModifier {
    @State private var showPanel = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                #if DEBUG
                showPanel = true
                #endif
            }
            .sheet(isPresented: $showPanel) {
                CCDiagnosticPanelView()
            }
    }
}

extension View {
    /// 在 DEBUG 模式下摇晃手机弹出诊断面板
    func withDiagnosticPanel() -> some View {
        #if DEBUG
        return self.modifier(ShakePresentDiagnosticPanel())
        #else
        return self
        #endif
    }
}
