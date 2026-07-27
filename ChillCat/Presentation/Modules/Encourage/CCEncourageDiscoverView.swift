import Combine
import SwiftUI

// MARK: - EncourageDiscoverView v3.0
/// 鼓励链发现页
/// 包含：横向卡片 + 搜索 + 按情绪标签筛选

struct EncourageDiscoverView: View {
    @StateObject private var viewModel = EncourageDiscoverViewModel()
    @State private var selectedChain: EncourageChainData? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: XuanSpacing.xl) {
                // 标题区域
                headerSection
                
                // 搜索栏
                searchBar
                
                // 情绪标签筛选
                emotionFilterSection
                
                // 正在发生的温暖 - 横向卡片
                activeChainsSection
                
                // 推荐加入的链
                recommendedChainsSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("鼓励链")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $selectedChain) { chain in
            EncouragePassView(chain: chain)
        }
        .debugAction(id: "encourage.refresh", pageName: "Encourage", label: "刷新鼓励链列表") { [viewModel] in
            Task { await viewModel.loadChains() }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            Text("传递温暖")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
            
            Text("每一句鼓励都是一束光，照亮他人的世界")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .padding(.top, XuanSpacing.sm)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: XuanSpacing.md) {
            Image("common_search")
                .font(.system(size: 16))
                .foregroundColor(Color.xuanTextTertiary)
            
            TextField("搜索鼓励语、话题...", text: $viewModel.searchText)
                .font(XuanFont.bodyL)
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.vertical, XuanSpacing.md)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.full))
    }
    
    // MARK: - Emotion Filter
    private var emotionFilterSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("按情绪筛选")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XuanSpacing.sm) {
                    FilterChip(
                        label: "全部",
                        isSelected: viewModel.selectedEmotion == nil,
                        color: Color.xuanApricot
                    ) {
                        viewModel.selectedEmotion = nil
                    }
                    
                    ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                        FilterChip(
                            label: emotion.chinese,
                            isSelected: viewModel.selectedEmotion == emotion.chinese,
                            color: emotion.color
                        ) {
                            viewModel.selectedEmotion = emotion.chinese
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Active Chains
    private var activeChainsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Label {
                    Text("正在发生的温暖")
                } icon: {
                    Image("resonance_like")
                }
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.activeChainCount)条链")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanApricotDark)
                    .padding(.horizontal, XuanSpacing.md)
                    .padding(.vertical, XuanSpacing.xs)
                    .background(Color(hex: "FDF0D5"))
                    .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XuanSpacing.md) {
                    ForEach(viewModel.activeChains) { chain in
                        ActiveChainCard(chain: chain)
                            .frame(width: 200)
                            .onTapGesture {
                                selectedChain = chain
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Recommended
    private var recommendedChainsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("推荐加入")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            VStack(spacing: XuanSpacing.md) {
                ForEach(viewModel.recommendedChains) { chain in
                    RecommendedChainRow(chain: chain) {
                        selectedChain = chain
                    }
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(XuanFont.bodyS)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.sm)
                .background(isSelected ? color : color.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Active Chain Card
struct ActiveChainCard: View {
    let chain: EncourageChainData
    
    var body: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            // 情绪标签
            HStack {
                Text(chain.emotionEmoji)
                    .font(.system(size: 28))
                
                Spacer()
                
                Text("\(chain.participantCount)人")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
                    .padding(.horizontal, XuanSpacing.sm)
                    .padding(.vertical, 2)
                    .background(Color.xuanSurface)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                Text(chain.theme)
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)
                    .lineLimit(2)
                
                Text(chain.latestMessage)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 底部信息
            HStack {
                ForEach(chain.emotionTags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(XuanFont.caption)
                        .foregroundColor(EmotionColors.color(for: tag))
                        .padding(.horizontal, XuanSpacing.sm)
                        .padding(.vertical, 2)
                        .background(EmotionColors.color(for: tag).opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
        .padding(XuanSpacing.lg)
        .frame(height: 180)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.xuanApricotDark.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Recommended Chain Row
struct RecommendedChainRow: View {
    let chain: EncourageChainData
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: XuanSpacing.md) {
                Text(chain.emotionEmoji)
                    .font(.system(size: 32))
                    .frame(width: 48, height: 48)
                    .background(Color(hex: "FDF0D5"))
                    .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chain.theme)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("\(chain.participantCount)人参与 · 最新：\(String(chain.latestMessage.prefix(20)))")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                
                Spacer()
                
                Image("common_more")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextTertiary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
}

// MARK: - ViewModel
@MainActor
final class EncourageDiscoverViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedEmotion: String? = nil
    @Published var activeChains: [EncourageChainData] = []
    @Published var recommendedChains: [EncourageChainData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var activeChainCount: Int { activeChains.count }
    
    init() {
        Task { await loadChains() }
    }
    
    func loadChains() async {
        isLoading = true
        errorMessage = nil
        do {
            let chains = try await CCXuanAPI.listChains()
            let mapped = chains.map { Self.mapToDiscoverChain($0) }
            activeChains = Array(mapped.prefix(max(0, mapped.count - 2)))
            recommendedChains = mapped.count >= 2 ? Array(mapped.suffix(2)) : []
        } catch {
            activeChains = []
            recommendedChains = []
            errorMessage = "鼓励链加载失败"
            LogW("API failed: \(error)", module: .network, category: "EncourageDiscover")
        }
        isLoading = false
    }
    
    private static func mapToDiscoverChain(_ chain: CCXuanAPI.ChainResponse) -> EncourageChainData {
        let links = chain.links ?? []
        let latestLink = links.last
        return EncourageChainData(
            id: String(chain.chainId ?? 0),
            theme: (links.first?.content ?? "鼓励链").prefix(15) + "…",
            latestMessage: latestLink?.content ?? "",
            emotionEmoji: "💪",
            emotionTags: [],
            participantCount: Int(chain.participantCount ?? 0),
            messages: links.map { EncourageMessageData(id: String($0.id), content: $0.content ?? "", from: "参与者", emoji: "💛", timeAgo: $0.createdAt ?? "") },
            createdAt: latestLink?.createdAt ?? ""
        )
    }
}

// MARK: - Data Model
struct EncourageChainData: Identifiable {
    let id: String
    let theme: String
    let latestMessage: String
    let emotionEmoji: String
    let emotionTags: [String]
    let participantCount: Int
    var messages: [EncourageMessageData]
    let createdAt: String
}

struct EncourageMessageData: Identifiable {
    let id: String
    let content: String
    let from: String
    let emoji: String
    let timeAgo: String
}

#Preview {
    NavigationStack {
        EncourageDiscoverView()
    }
}
