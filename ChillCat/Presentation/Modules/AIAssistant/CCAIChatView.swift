import Combine
import SwiftUI

// MARK: - AIChatView v3.0 (Week 2 完善)
/// AI对话页面 - 完整实现
/// 包含：多轮对话气泡列表、语音输入、快捷话题、加载动画、安全协议触发态、10轮上下文提示
struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showVoiceRecorder: Bool = false
    @State private var showContextWarning: Bool = false
    @State private var showSafetyProtocol: Bool = false
    @State private var showNewConversationDialog: Bool = false

    var body: some View {
        ZStack {
            // 主界面
            VStack(spacing: 0) {
                // AI陪伴标识栏
                aiCompanionHeader

                // 对话区域
                if showSafetyProtocol {
                    safetyProtocolView
                } else {
                    chatList
                }

                // 输入区域
                if !showSafetyProtocol {
                    inputArea
                }
            }
            .background(Color.xuanApricotBg)
            .onTapGesture {
                isInputFocused = false
            }

            // 语音录制覆盖层
            if showVoiceRecorder {
                voiceRecorderOverlay
            }
        }
        .confirmationDialog("是否开始新对话？", isPresented: $showNewConversationDialog, titleVisibility: .visible) {
            Button("开始新对话") {
                viewModel.startNewConversation()
            }
            Button("继续当前对话", role: .cancel) {
                viewModel.dismissContextWarning()
            }
        } message: {
            Text("对话已超过10轮，AI的记忆有限，开启新对话可以获得更好的体验。")
        }
    }

    // MARK: - AI Companion Header
    private var aiCompanionHeader: some View {
        HStack(spacing: XuanSpacing.md) {
            // AI头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.xuanTextSecondary, Color(hex: "A085C6").opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image("home_mood")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI 倾听官")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)

                HStack(spacing: 4) {
                    ComponentStyles.PulseIndicator(color: Color.xuanSuccess)

                    Text("在线 · 随时倾听")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanSuccess)
                }
            }

            Spacer()

            // 对话轮次指示
            if viewModel.userMessageCount > 0 {
                Text("第\(min(viewModel.userMessageCount, 10))/10轮")
                    .font(XuanFont.caption)
                    .foregroundColor(
                        viewModel.userMessageCount >= 10
                            ? Color.xuanDanger
                            : Color.xuanTextTertiary
                    )
                    .padding(.horizontal, XuanSpacing.sm)
                    .padding(.vertical, 2)
                    .background(
                        viewModel.userMessageCount >= 10
                            ? Color(hex: "FFDAD5")
                            : Color.xuanSurface
                    )
                    .clipShape(Capsule())
            }

            // 更多操作
            Button {
                viewModel.showOptions()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .accessibilityLabel("更多选项")
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.vertical, XuanSpacing.md)
        .background(.regularMaterial)
    }

    // MARK: - Chat List
    private var chatList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: XuanSpacing.lg) {
                    // 欢迎消息（首次）
                    if viewModel.messages.isEmpty {
                        welcomeMessage
                    }

                    // 上下文提示横幅
                    if viewModel.showContextWarning {
                        contextWarningBanner
                    }

                    // 对话气泡
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    // 加载动画
                    if viewModel.isAIResponding {
                        typingIndicatorWithText
                            .id("typing")
                    }

                    // 底部间距
                    Spacer().frame(height: XuanSpacing.sm)
                }
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.md)
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isAIResponding) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        VStack(spacing: XuanSpacing.lg) {
            Spacer().frame(height: XuanSpacing.xl2)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.xuanTextSecondary.opacity(0.2), Color(hex: "A085C6").opacity(0.5).opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image("home_mood")
                    .font(.system(size: 36))
                    .foregroundColor(Color.xuanTextSecondary)
            }

            Text("嗨，我在这里")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            Text("无论你想说什么，我都会认真倾听\n这里很安全，你可以做真实的自己")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // 快捷话题入口
            quickTopicsSection
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Topics
    private var quickTopicsSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("或许你想聊聊这些？")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextTertiary)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: XuanSpacing.sm
            ) {
                ForEach(viewModel.quickTopics, id: \.self) { topic in
                    Button {
                        viewModel.sendQuickTopic(topic)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: topicIcon(for: topic))
                                .font(.system(size: 13))
                            Text(topic)
                                .font(XuanFont.bodyS)
                                .lineLimit(1)
                        }
                        .foregroundColor(Color.xuanTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, XuanSpacing.md)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                        .xuanCardShadow()
                    }
                    .accessibilityHint("双击发送这个话题")
                }
            }
        }
        .padding(.top, XuanSpacing.sm)
    }

    private func topicIcon(for topic: String) -> String {
        if topic.contains("焦虑") { return "waveform.path.ecg" }
        if topic.contains("难过") { return "cloud.rain.fill" }
        if topic.contains("好消息") { return "sparkles" }
        if topic.contains("压力") { return "exclamationmark.bubble" }
        if topic.contains("放松") { return "leaf.fill" }
        if topic.contains("情绪") { return "heart.text.square" }
        return "bubble.left.and.bubble.right"
    }

    // MARK: - Context Warning Banner
    private var contextWarningBanner: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.xuanApricotDark)

            VStack(alignment: .leading, spacing: 2) {
                Text("对话较长，是否开始新对话？")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextPrimary)

                Text("已超过10轮，AI的记忆有限")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Spacer()

            Button("新对话") {
                showNewConversationDialog = true
            }
            .font(XuanFont.bodyS)
            .foregroundColor(.white)
            .padding(.horizontal, XuanSpacing.md)
            .padding(.vertical, XuanSpacing.xs)
            .background(Color.xuanApricot)
            .clipShape(Capsule())
        }
        .padding()
        .background(Color(hex: "FDF0D5"))
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.xuanApricotDark.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Safety Protocol View
    private var safetyProtocolView: some View {
        VStack(spacing: XuanSpacing.xl2) {
            Spacer()

            // 安全图标
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "FFDAD5").opacity(0.6),
                                Color(hex: "FFDAD5").opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color.xuanDanger)
            }

            // 危机响应文本
            VStack(spacing: XuanSpacing.md) {
                Text("我们注意到你现在的状态")
                    .font(XuanFont.h2)
                    .foregroundColor(Color.xuanTextPrimary)

                Text("你并不孤单，这些资源可能对你有帮助：")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // 紧急资源
            VStack(spacing: XuanSpacing.md) {
                SafetyResourceCard(
                    title: "全国心理援助热线",
                    subtitle: "24小时免费咨询",
                    number: "400-161-9995",
                    color: Color.xuanDanger
                )

                SafetyResourceCard(
                    title: "北京心理危机研究与干预中心",
                    subtitle: "专业危机干预",
                    number: "010-82951332",
                    color: Color.xuanApricotDark
                )

                SafetyResourceCard(
                    title: "生命热线",
                    subtitle: "希望24热线",
                    number: "400-161-9995",
                    color: Color(hex: "7CB8B0")
                )
            }

            // 返回对话
            Button {
                showSafetyProtocol = false
            } label: {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("返回对话")
                }
                .font(XuanFont.bodyLBold)
                .foregroundColor(Color.xuanApricot)
                .padding(.horizontal, XuanSpacing.xl2)
                .padding(.vertical, XuanSpacing.md)
                .background(Color(hex: "F2DBC9"))
                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
            }

            Spacer()
        }
        .padding(XuanSpacing.xl)
        .background(Color.xuanApricotBg)
    }

    // MARK: - Typing Indicator with Text
    private var typingIndicatorWithText: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            HStack(alignment: .top, spacing: XuanSpacing.sm) {
                // AI头像小
                ZStack {
                    Circle()
                        .fill(Color.xuanTextSecondary.opacity(0.3))
                        .frame(width: 28, height: 28)

                    Image("home_mood")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanTextSecondary)
                }

                // 加载文字
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("正在理解你的感受…")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)

                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.xuanTextTertiary)
                                .frame(width: 7, height: 7)
                                .opacity(viewModel.typingDotOpacity[index] ? 1 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: viewModel.typingDotOpacity[index]
                                )
                        }
                    }
                }
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.md)
                .background(Color.xuanSurface)
                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))

                Spacer()
            }
            .onAppear {
                viewModel.startTypingAnimation()
            }

            // "AI陪伴"标识
            Text("AI陪伴")
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextTertiary)
                .padding(.leading, 36)
        }
    }

    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider().foregroundColor(Color.xuanBorder)

            HStack(alignment: .bottom, spacing: XuanSpacing.sm) {
                // 语音输入按钮
                Button {
                    showVoiceRecorder = true
                } label: {
                    Image("ai_listen")
                        .font(.system(size: 22))
                        .foregroundColor(Color.xuanTextSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("语音输入")

                // 文字输入框
                TextField("说说你的想法...", text: $viewModel.inputText, axis: .vertical)
                    .font(XuanFont.bodyL)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.lg)
                    .focused($isInputFocused)
                    .lineLimit(1...5)

                // 发送按钮
                Button {
                    viewModel.sendMessage()
                    isInputFocused = false
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.xuanTextTertiary
                                : Color.xuanApricot
                        )
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, XuanSpacing.md)
            .padding(.vertical, XuanSpacing.sm)
        }
        .background(.regularMaterial)
    }

    // MARK: - Voice Recorder Overlay
    private var voiceRecorderOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showVoiceRecorder = false
                }

            VoiceRecorderView(
                maxDuration: 60,
                onTranscription: { text in
                    viewModel.inputText = text
                    showVoiceRecorder = false
                    viewModel.sendMessage()
                },
                onCancel: {
                    showVoiceRecorder = false
                }
            )
            .padding(.horizontal, XuanSpacing.xl)
        }
    }

    // MARK: - Helpers
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isAIResponding {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastId = viewModel.messages.last?.id {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

// MARK: - Safety Resource Card
struct SafetyResourceCard: View {
    let title: String
    let subtitle: String
    let number: String
    let color: Color

    var body: some View {
        HStack(spacing: XuanSpacing.md) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image("alert_call")
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextPrimary)
                Text(subtitle)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Spacer()

            Button {
                if let url = URL(string: "tel://\(number.replacingOccurrences(of: "-", with: ""))") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(number)
                    .font(XuanFont.bodyS)
                    .foregroundColor(color)
                    .padding(.horizontal, XuanSpacing.md)
                    .padding(.vertical, XuanSpacing.xs)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: XuanSpacing.sm) {
            if message.isFromAI {
                aiAvatar
            } else {
                Spacer()
            }

            VStack(alignment: message.isFromAI ? .leading : .trailing, spacing: 4) {
                Text(message.content)
                    .font(XuanFont.bodyL)
                    .foregroundColor(message.isFromAI ? Color.xuanTextPrimary : .white)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.md)
                    .background(
                        message.isFromAI
                            ? AnyView(Color.xuanSurface)
                            : AnyView(Color.xuanApricot)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))

                HStack(spacing: 4) {
                    Text(message.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)

                    // "AI陪伴"标识在AI消息下方
                    if message.isFromAI {
                        Text("· AI陪伴")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                }
            }

            if !message.isFromAI {
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isFromAI ? "AI" : "你")：\(message.content)")
    }

    private var aiAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.xuanTextSecondary.opacity(0.2))
                .frame(width: 28, height: 28)

            Image("home_mood")
                .font(.system(size: 14))
                .foregroundColor(Color.xuanTextSecondary)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - View Model
@MainActor
final class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isAIResponding = false
    @Published var typingDotOpacity: [Bool] = [false, false, false]
    @Published var showContextWarning: Bool = false
    @Published var isSafetyProtocolTriggered: Bool = false

    private let maxContextRounds: Int = 10
    private var contextWarningDismissed: Bool = false

    var userMessageCount: Int {
        messages.filter { !$0.isFromAI }.count
    }

    let quickTopics = [
        "我有点焦虑",
        "今天很难过",
        "分享一个好消息",
        "最近压力很大",
        "教我放松方法",
        "帮我分析情绪"
    ]

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 检测安全关键词触发危机响应
        if isSafetyKeyword(text) {
            isSafetyProtocolTriggered = true
            inputText = ""
            return
        }

        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: text,
            isFromAI: false,
            timestamp: Date()
        )
        messages.append(userMessage)
        inputText = ""

        // 检查上下文轮次
        checkContextLimit()

        // 模拟AI回复
        simulateAIResponse()
    }

    func sendQuickTopic(_ topic: String) {
        inputText = topic
        sendMessage()
    }

    func startVoiceInput() {
        // 由VoiceRecorderView处理
    }

    func showOptions() {
        // 更多选项
    }

    func startNewConversation() {
        messages.removeAll()
        showContextWarning = false
        contextWarningDismissed = false
    }

    func dismissContextWarning() {
        contextWarningDismissed = true
        showContextWarning = false
    }

    func startTypingAnimation() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.typingDotOpacity[i] = true
            }
        }
    }

    // MARK: - Private

    private func checkContextLimit() {
        if userMessageCount >= maxContextRounds && !contextWarningDismissed {
            showContextWarning = true
        }
    }

    private func isSafetyKeyword(_ text: String) -> Bool {
        let keywords = [
            "不想活了", "自杀", "结束生命", "活着没意思",
            "想死", "没有希望了", "撑不下去了"
        ]
        return keywords.contains { text.contains($0) }
    }

    private func simulateAIResponse() {
        isAIResponding = true

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            let responses: [String]
            let lastMessage = messages.last?.content.lowercased() ?? ""

            if lastMessage.contains("焦虑") {
                responses = [
                    "我听到了你的焦虑。这种感觉让人很不舒服，但你愿意说出来已经是很勇敢的一步了。能具体说说是什么让你感到焦虑吗？",
                    "焦虑是我们身体的一种保护机制，它在提醒我们需要关注某些事情。让我陪你一起梳理一下，好吗？"
                ]
            } else if lastMessage.contains("难过") {
                responses = [
                    "难过的时候，允许自己哭一会儿也没关系。我在这里陪着你。",
                    "谢谢你愿意告诉我你的难过。这种感觉会过去的，而你不需要一个人面对。"
                ]
            } else if lastMessage.contains("压力") {
                responses = [
                    "压力大的时候，我们常常会忘记自己已经做得很好了。你最近在为什么事情感到压力呢？",
                    "适当的压力可以推动我们前进，但太多的时候需要停下来喘口气。你给自己留休息的时间了吗？"
                ]
            } else if lastMessage.contains("开心") || lastMessage.contains("好消息") {
                responses = [
                    "太好了！开心的时刻值得被记住。能和我分享更多细节吗？",
                    "真为你高兴！这些积极的时刻是我们继续前行的动力。"
                ]
            } else if lastMessage.contains("放松") {
                responses = [
                    "让我教你一个简单的放松方法：闭上眼睛，慢慢地吸气4秒，屏住呼吸4秒，再慢慢地呼气6秒。重复几次，感受身体的变化。",
                    "放松不是逃避，而是为了更好地面对。试试把注意力放在你的呼吸上，感受空气进入和离开身体的感觉。"
                ]
            } else {
                responses = [
                    "我听到了你的感受。这种感觉是完全可以理解的，你愿意多说说吗？",
                    "谢谢你愿意和我分享这些。在这里你可以完全放松，我会一直陪着你。",
                    "你的情绪很重要，让我们一起慢慢梳理，好吗？",
                    "我能感受到你的心情。有时候说出来本身就是一种释放。",
                    "每个人的情绪都值得被认真对待，包括你的。我们慢慢来。"
                ]
            }

            let aiMessage = ChatMessage(
                id: UUID().uuidString,
                content: responses.randomElement() ?? responses[0],
                isFromAI: true,
                timestamp: Date()
            )
            messages.append(aiMessage)
            isAIResponding = false
        }
    }
}

// MARK: - Data Model
struct ChatMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let isFromAI: Bool
    let timestamp: Date

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    NavigationStack {
        AIChatView()
    }
}
