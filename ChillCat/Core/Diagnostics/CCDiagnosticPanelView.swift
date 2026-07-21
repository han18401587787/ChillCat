import SwiftUI

#if DEBUG

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
    @State private var screenshot: UIImage?
    @State private var isCapturing = false
    @State private var isSubmitting = false
    @State private var submitResult: SubmitResult?
    @State private var showTokenSetup = false

    private let reporter = CCGitHubIssueReporter.shared

    enum SubmitResult {
        case success(issueURL: String)
        case failure(message: String)
    }

    // MARK: - Bug 报告正文（Markdown）

    private var bugReportMarkdown: String {
        var lines = [
            "## Bug 报告",
            "",
            "| 字段 | 内容 |",
            "|------|------|",
            "| **页面** | \(pageName) |",
            "| **时间** | \(ISO8601DateFormatter().string(from: Date())) |",
            "| **设备** | \(UIDevice.current.model) · iOS \(UIDevice.current.systemVersion) |",
            "| **App版本** | \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知") |",
            "",
            "### 问题描述",
            description.isEmpty ? "(待补充)" : description,
            "",
            "### 期望结果",
            expectedResult.isEmpty ? "(待补充)" : expectedResult,
            "",
            "### 实际结果",
            actualResult.isEmpty ? "(待补充)" : actualResult,
            "",
            "### 复现步骤",
            "1. 打开「\(pageName)」页面",
            "2. (请补充具体操作)",
            "3. 观察到上述问题",
            "",
            "### 诊断日志",
            "```",
        ]

        for event in recentEvents {
            lines.append("[\(event.formattedTime)] [\(event.level.rawValue)] [\(event.module)] \(event.message)")
            if let err = event.errorDescription {
                lines.append("  └─ \(err)")
            }
        }

        lines.append("```")
        return lines.joined(separator: "\n")
    }

    private var bugReportPlain: String {
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
                // 截图预览
                Section("截图（自动捕获）") {
                    if let screenshot = screenshot {
                        HStack {
                            Spacer()
                            Image(uiImage: screenshot)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    } else {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 36))
                                    .foregroundColor(.secondary)
                                Text("截图将在提交时自动捕获当前页面")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 16)
                            Spacer()
                        }
                    }
                }

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

                // 提交状态
                if let result = submitResult {
                    Section {
                        switch result {
                        case .success(let url):
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Issue 已创建")
                                        .fontWeight(.semibold)
                                }
                                Text(url)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        if let url = URL(string: url) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                            }
                        case .failure(let msg):
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(msg)
                                    .font(.caption)
                            }
                        }
                    }
                }

                // 操作按钮
                Section {
                    // 提交到 GitHub
                    if reporter.hasToken {
                        Button(action: { submitToGitHub() }) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("提交中...")
                                } else {
                                    Label("提交到 GitHub Issue", systemImage: "arrow.up.circle.fill")
                                }
                            }
                        }
                        .disabled(isSubmitting || description.isEmpty)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("需要配置 GitHub Token", systemImage: "key.fill")
                                .foregroundColor(.orange)
                            Text("首次使用需要设置 Personal Access Token，之后无需重复配置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button("设置 Token") {
                                showTokenSetup = true
                            }
                            .font(.caption)
                        }
                    }

                    // 复制到剪贴板（备用）
                    Button(action: {
                        UIPasteboard.general.string = bugReportPlain
                    }) {
                        Label("复制到剪贴板", systemImage: "doc.on.doc")
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
            .sheet(isPresented: $showTokenSetup) {
                TokenSetupView(onSave: { showTokenSetup = false })
            }
        }
    }

    // MARK: - 提交到 GitHub

    private func submitToGitHub() {
        guard !description.isEmpty else { return }
        isSubmitting = true
        submitResult = nil

        // 先截取当前页面
        let capturedScreenshot = captureScreen()
        screenshot = capturedScreenshot

        let title = "[Bug] \(pageName): \(description.prefix(80))"
        let body = bugReportMarkdown

        Task {
            do {
                let issueURL = try await reporter.submit(
                    title: title,
                    body: body,
                    screenshot: capturedScreenshot?.pngData()
                )
                submitResult = .success(issueURL: issueURL)
                // 自动复制 Issue 链接
                UIPasteboard.general.string = issueURL
                LogI("Bug 已提交到 GitHub: \(issueURL)", module: .ui, category: "BugReport")
            } catch {
                submitResult = .failure(message: error.localizedDescription)
                LogE("Bug 提交失败: \(error.localizedDescription)", module: .ui, category: "BugReport", error: error)
            }
            isSubmitting = false
        }
    }

    /// 截取当前窗口屏幕
    private func captureScreen() -> UIImage? {
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

// MARK: - Token 配置 Sheet

private struct TokenSetupView: View {
    let onSave: () -> Void
    @State private var token: String = ""
    @State private var showGuide = false

    private let reporter = CCGitHubIssueReporter.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("需要 GitHub Personal Access Token 来创建 Issue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Token") {
                    SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $token)
                        .font(.caption)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    Button("获取 Token 指南") {
                        showGuide = true
                    }
                } header: {
                    Text("如何获取")
                } footer: {
                    Text("Token 仅保存在本地，仅用于创建 Issue")
                }

                Section {
                    Button("保存") {
                        reporter.saveToken(token)
                        onSave()
                    }
                    .disabled(token.isEmpty)
                }
            }
            .navigationTitle("GitHub Token")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { onSave() }
                }
            }
            .sheet(isPresented: $showGuide) {
                TokenGuideView()
            }
        }
    }
}

private struct TokenGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("获取 GitHub Token 步骤")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. 打开 GitHub Settings")
                        Link("https://github.com/settings/tokens",
                             destination: URL(string: "https://github.com/settings/tokens")!)
                        .font(.caption)
                    }

                    Text("2. 点击「Generate new token」→「Generate new token (classic)」")

                    Text("3. 勾选权限：")
                    Text("   ☑ repo (完整仓库访问权限)")
                        .font(.caption)

                    Text("4. 点击「Generate token」并复制")

                    Text("5. 粘贴到上一步的输入框")

                    Text("注意：Token 仅保存在手机本地，不会上传到任何服务器")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Token 指南")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#endif // DEBUG — 以上所有类型仅在 DEBUG 编译

// MARK: - 摇晃手势扩展（所有模式可用）

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

// MARK: - 摇晃弹出 Modifier（条件编译）

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
                #if DEBUG
                CCDiagnosticPanelView()
                #endif
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
