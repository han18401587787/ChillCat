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
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
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
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("鼓励链")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $selectedChain) { chain in
            EncouragePassView(chain: chain)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("传递温暖")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("每一句鼓励都是一束光，照亮他人的世界")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.top, AppSpacing.sm)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textTertiary)
            
            TextField("搜索鼓励语、话题...", text: $viewModel.searchText)
                .font(AppFont.body)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.full))
    }
    
    // MARK: - Emotion Filter
    private var emotionFilterSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("按情绪筛选")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterChip(
                        label: "全部",
                        isSelected: viewModel.selectedEmotion == nil,
                        color: AppTheme.primary
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
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Label("正在发生的温暖", systemImage: "heart.circle.fill")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.activeChainCount)条链")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.warmGlow)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppTheme.warmGlowLight)
                    .clipShape(Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
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
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("推荐加入")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
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
                .font(AppFont.footnote)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? color : color.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Active Chain Card
struct ActiveChainCard: View {
    let chain: EncourageChainData
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // 情绪标签
            HStack {
                Text(chain.emotionEmoji)
                    .font(.system(size: 28))
                
                Spacer()
                
                Text("\(chain.participantCount)人")
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 2)
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(chain.theme)
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                Text(chain.latestMessage)
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 底部信息
            HStack {
                ForEach(chain.emotionTags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(AppFont.caption2)
                        .foregroundColor(EmotionColors.color(for: tag))
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 2)
                        .background(EmotionColors.color(for: tag).opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
        .padding(AppSpacing.lg)
        .frame(height: 180)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppTheme.warmGlow.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Recommended Chain Row
struct RecommendedChainRow: View {
    let chain: EncourageChainData
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Text(chain.emotionEmoji)
                    .font(.system(size: 32))
                    .frame(width: 48, height: 48)
                    .background(AppTheme.warmGlowLight)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chain.theme)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(chain.participantCount)人参与 · 最新：\(String(chain.latestMessage.prefix(20)))")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
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
            print("⚠️ [EncourageDiscover] API failed: \(error)")
        }
        isLoading = false
    }
    
    private static func mapToDiscoverChain(_ chain: CCXuanAPI.ChainResponse) -> EncourageChainData {
        let latestLink = chain.links.last
        return EncourageChainData(
            id: String(chain.chainId),
            theme: chain.links.first?.content.prefix(15).appending("…") ?? "鼓励链",
            latestMessage: latestLink?.content ?? "",
            emotionEmoji: "💪",
            emotionTags: [],
            participantCount: Int(chain.participantCount),
            messages: chain.links.map { EncourageMessageData(id: String($0.id), content: $0.content, from: "参与者", emoji: "💛", timeAgo: $0.createdAt) },
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
