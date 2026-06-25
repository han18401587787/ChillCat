import Combine
import SwiftUI

// MARK: - EncouragePassView v3.0
/// 鼓励链传递页
/// 阅读链上内容 + 编辑鼓励语(≤50字) + 预设话术选择 + 发送

struct EncouragePassView: View {
    @StateObject private var viewModel: EncouragePassViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSendAnimation = false
    @State private var isSending = false
    
    init(chain: EncourageChainData) {
        _viewModel = StateObject(wrappedValue: EncouragePassViewModel(chain: chain))
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // 链主题
                    chainHeader
                    
                    // 链上的鼓励消息
                    messageChain
                    
                    // 预设话术
                    presetPhrasesSection
                    
                    // 编辑鼓励语
                    composeSection
                    
                    // 发送按钮
                    sendButton
                    
                    Spacer(minLength: 40)
                }
                .padding(AppSpacing.lg)
            }
        }
        .navigationTitle("传递鼓励")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("返回") {
                    dismiss()
                }
                .foregroundColor(AppTheme.primary)
            }
        }
        .overlay {
            if showSendAnimation {
                sendSuccessOverlay
            }
        }
    }
    
    // MARK: - Chain Header
    private var chainHeader: some View {
        VStack(spacing: AppSpacing.md) {
            Text(viewModel.chain.emotionEmoji)
                .font(.system(size: 48))
            
            Text(viewModel.chain.theme)
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
                
                Text("已有 \(viewModel.chain.participantCount) 人参与")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.top, AppSpacing.lg)
    }
    
    // MARK: - Message Chain
    private var messageChain: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("链上的温暖")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            VStack(spacing: AppSpacing.md) {
                ForEach(viewModel.chainMessages) { message in
                    ChainMessageBubble(message: message)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Preset Phrases
    private var presetPhrasesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("选择一句鼓励话术")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                ForEach(viewModel.presetPhrases, id: \.self) { phrase in
                    Button {
                        viewModel.selectPreset(phrase)
                    } label: {
                        Text(phrase)
                            .font(AppFont.footnote)
                            .foregroundColor(
                                viewModel.encourageText == phrase
                                    ? AppTheme.warmGlowDark
                                    : AppTheme.textSecondary
                            )
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.encourageText == phrase
                                    ? AppTheme.warmGlowLight
                                    : AppTheme.backgroundSecondary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(
                                        viewModel.encourageText == phrase
                                            ? AppTheme.warmGlow.opacity(0.5)
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Compose Section
    private var composeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("写下你的鼓励")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
                
                Text("\(viewModel.encourageText.count)/50")
                    .font(AppFont.footnote)
                    .foregroundColor(
                        viewModel.encourageText.count > 50
                            ? AppTheme.crisisRed
                            : AppTheme.textTertiary
                    )
            }
            
            TextEditor(text: $viewModel.encourageText)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textPrimary)
                .frame(minHeight: 100)
                .padding(AppSpacing.md)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .onChange(of: viewModel.encourageText) { newValue in
                    if newValue.count > 50 {
                        viewModel.encourageText = String(newValue.prefix(50))
                    }
                }
        }
    }
    
    // MARK: - Send Button
    private var sendButton: some View {
        Button {
            isSending = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isSending = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showSendAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if isSending {
                    ProgressView()
                        .tint(.white)
                }
                
                Image(systemName: "paperplane.fill")
                Text(isSending ? "发送中..." : "传递鼓励")
            }
        }
        .buttonStyle(ComponentStyles.PrimaryButtonStyle())
        .disabled(viewModel.encourageText.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
        .opacity(viewModel.encourageText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
    }
    
    // MARK: - Send Success Overlay
    private var sendSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(AppTheme.warmGlow.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.warmGlow)
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("温暖已传递")
                        .font(AppFont.title2)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("你的鼓励会照亮某个人的世界")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(AppSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppTheme.surface)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
            )
        }
    }
}

// MARK: - Chain Message Bubble
struct ChainMessageBubble: View {
    let message: EncourageMessageData
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text(message.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(AppTheme.warmGlowLight)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
                
                HStack(spacing: AppSpacing.sm) {
                    Text(message.from)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text("·")
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text(message.timeAgo)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

// MARK: - ViewModel
@MainActor
final class EncouragePassViewModel: ObservableObject {
    let chain: EncourageChainData
    
    @Published var encourageText: String = ""
    @Published var chainMessages: [EncourageMessageData] = []
    
    let presetPhrases: [String] = [
        "你比自己想象的更勇敢",
        "今天的你也很努力了",
        "一切都会慢慢好起来的",
        "你不是一个人在战斗",
        "温柔对待自己也是一种勇气",
        "每一个明天都值得期待",
        "深呼吸，你已经做得很好了",
        "你的存在本身就是一种美好",
        "允许自己有不好的情绪",
        "坚持到今天的你，真的很棒",
        "相信自己，你可以的",
        "累了就休息，没关系的",
    ]
    
    init(chain: EncourageChainData) {
        self.chain = chain
        loadMockMessages()
    }
    
    func selectPreset(_ phrase: String) {
        encourageText = phrase
    }
    
    private func loadMockMessages() {
        chainMessages = [
            EncourageMessageData(
                id: "m1",
                content: "我知道这不容易，但你已经坚持到现在了，真的很了不起",
                from: "暖心伙伴",
                emoji: "💪",
                timeAgo: "3小时前"
            ),
            EncourageMessageData(
                id: "m2",
                content: "每个人都有自己的节奏，不必和任何人比较",
                from: "同行者",
                emoji: "🌟",
                timeAgo: "2小时前"
            ),
            EncourageMessageData(
                id: "m3",
                content: "别忘了，你今天已经完成了那么多事，给自己点个赞吧",
                from: "阳光使者",
                emoji: "☀️",
                timeAgo: "1小时前"
            ),
        ]
    }
}

#Preview {
    NavigationStack {
        EncouragePassView(
            chain: EncourageChainData(
                id: "1",
                theme: "给今天也在努力的你",
                latestMessage: "",
                emotionEmoji: "💪",
                emotionTags: ["希望", "感恩"],
                participantCount: 47,
                messages: [],
                createdAt: ""
            )
        )
    }
}
