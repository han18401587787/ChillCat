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
            Color.xuanApricotBg
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: XuanSpacing.xl) {
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
                .padding(XuanSpacing.lg)
            }
        }
        .navigationTitle("传递鼓励")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("返回") {
                    dismiss()
                }
                .foregroundColor(Color.xuanApricot)
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
        VStack(spacing: XuanSpacing.md) {
            Text(viewModel.chain.emotionEmoji)
                .font(.system(size: 48))
            
            Text(viewModel.chain.theme)
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: XuanSpacing.sm) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextTertiary)
                
                Text("已有 \(viewModel.chain.participantCount) 人参与")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .padding(.top, XuanSpacing.lg)
    }
    
    // MARK: - Message Chain
    private var messageChain: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("链上的温暖")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
            
            VStack(spacing: XuanSpacing.md) {
                ForEach(viewModel.chainMessages) { message in
                    ChainMessageBubble(message: message)
                }
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Preset Phrases
    private var presetPhrasesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("选择一句鼓励话术")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: XuanSpacing.sm) {
                ForEach(viewModel.presetPhrases, id: \.self) { phrase in
                    Button {
                        viewModel.selectPreset(phrase)
                    } label: {
                        Text(phrase)
                            .font(XuanFont.bodyS)
                            .foregroundColor(
                                viewModel.encourageText == phrase
                                    ? Color(hex: "B08A3A")
                                    : Color.xuanTextSecondary
                            )
                            .padding(XuanSpacing.md)
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.encourageText == phrase
                                    ? Color(hex: "FDF0D5")
                                    : Color.xuanSurface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: XuanRadius.md)
                                    .stroke(
                                        viewModel.encourageText == phrase
                                            ? Color.xuanApricotDark.opacity(0.5)
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
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("写下你的鼓励")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextTertiary)
                
                Spacer()
                
                Text("\(viewModel.encourageText.count)/50")
                    .font(XuanFont.bodyS)
                    .foregroundColor(
                        viewModel.encourageText.count > 50
                            ? Color.xuanDanger
                            : Color.xuanTextTertiary
                    )
            }
            
            TextEditor(text: $viewModel.encourageText)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .frame(minHeight: 100)
                .padding(XuanSpacing.md)
                .background(Color.xuanSurface)
                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: XuanRadius.md)
                        .stroke(Color.xuanBorder, lineWidth: 1)
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
            HStack(spacing: XuanSpacing.sm) {
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
            
            VStack(spacing: XuanSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.xuanApricotDark.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.xuanApricotDark)
                }
                
                VStack(spacing: XuanSpacing.sm) {
                    Text("温暖已传递")
                        .font(XuanFont.h2)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("你的鼓励会照亮某个人的世界")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
            .padding(XuanSpacing.xl2)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.xl)
                    .fill(Color.xuanSurface)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
            )
        }
    }
}

// MARK: - Chain Message Bubble
struct ChainMessageBubble: View {
    let message: EncourageMessageData
    
    var body: some View {
        HStack(alignment: .top, spacing: XuanSpacing.md) {
            Text(message.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(Color(hex: "FDF0D5"))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
                    .lineSpacing(4)
                
                HStack(spacing: XuanSpacing.sm) {
                    Text(message.from)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    Text("·")
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    Text(message.timeAgo)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
            
            Spacer()
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
    }
}

// MARK: - ViewModel
@MainActor
final class EncouragePassViewModel: ObservableObject {
    let chain: EncourageChainData
    
    @Published var encourageText: String = ""
    @Published var chainMessages: [EncourageMessageData] = []
    @Published var isLoadingMessages = false
    
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
        Task { await loadChainMessages() }
    }
    
    func selectPreset(_ phrase: String) {
        encourageText = phrase
    }
    
    func loadChainMessages() async {
        guard let chainId = Int64(chain.id) else { return }
        isLoadingMessages = true
        do {
            let chainData = try await CCXuanAPI.getChain(id: chainId)
            chainMessages = (chainData.links ?? []).map { link in
                EncourageMessageData(
                    id: String(link.id),
                    content: link.content ?? "",
                    from: "参与者",
                    emoji: "💛",
                    timeAgo: link.createdAt ?? ""
                )
            }
        } catch {
            print("⚠️ [EncouragePass] API failed: \(error)")
        }
        isLoadingMessages = false
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
