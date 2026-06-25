import Combine
import SwiftUI

// MARK: - EncourageMuseumView v3.0
/// 鼓励链博物馆
/// 已完成链展示 + 里程碑(10/50/100) + 善意勋章

struct EncourageMuseumView: View {
    @StateObject private var viewModel = EncourageMuseumViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // 头部统计
                statsHeader
                
                // 里程碑
                milestonesSection
                
                // 善意勋章
                badgesSection
                
                // 已完成的链
                completedChainsSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("善意博物馆")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("🏛️")
                .font(.system(size: 48))
            
            Text("你已传递 \(viewModel.totalKindnessCount) 份善意")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: AppSpacing.xxl) {
                StatItem(value: "\(viewModel.chainsInitiated)", label: "发起链", color: AppTheme.primary)
                StatItem(value: "\(viewModel.chainsJoined)", label: "参与链", color: AppTheme.warmGlow)
                StatItem(value: "\(viewModel.peopleReached)", label: "触达人数", color: AppTheme.roseGold)
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [AppTheme.warmGlowLight, AppTheme.roseGoldLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
    
    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("里程碑")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                MilestoneRow(
                    icon: "star.fill",
                    title: "温暖新手",
                    subtitle: "完成10次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 10.0,
                    isCompleted: viewModel.totalKindnessCount >= 10,
                    color: AppTheme.warmGlow
                )
                
                MilestoneRow(
                    icon: "sparkles",
                    title: "善意传播者",
                    subtitle: "完成50次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 50.0,
                    isCompleted: viewModel.totalKindnessCount >= 50,
                    color: AppTheme.roseGold
                )
                
                MilestoneRow(
                    icon: "crown.fill",
                    title: "温暖大使",
                    subtitle: "完成100次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 100.0,
                    isCompleted: viewModel.totalKindnessCount >= 100,
                    color: AppTheme.primary
                )
            }
            .sectionGroup()
        }
    }
    
    // MARK: - Badges
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("善意勋章")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                ForEach(viewModel.badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }
    
    // MARK: - Completed Chains
    private var completedChainsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("已完成的链")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                ForEach(viewModel.completedChains) { chain in
                    CompletedChainRow(chain: chain)
                }
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.title2)
                .foregroundColor(color)
            
            Text(label)
                .font(AppFont.caption2)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let progress: Double
    let isCompleted: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color : color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isCompleted ? "checkmark" : icon)
                    .font(.system(size: 16))
                    .foregroundColor(isCompleted ? .white : color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(subtitle)
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textTertiary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isCompleted ? color : color)
                            .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: KindnessBadge
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        badge.isUnlocked
                            ? badge.color.opacity(0.15)
                            : AppTheme.backgroundSecondary
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 28))
                    .foregroundColor(badge.isUnlocked ? badge.color : AppTheme.textTertiary)
                    .opacity(badge.isUnlocked ? 1.0 : 0.4)
            }
            
            Text(badge.name)
                .font(AppFont.caption2)
                .foregroundColor(
                    badge.isUnlocked ? AppTheme.textPrimary : AppTheme.textTertiary
                )
                .multilineTextAlignment(.center)
            
            if badge.isUnlocked {
                Text(badge.unlockDate)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Completed Chain Row
struct CompletedChainRow: View {
    let chain: CompletedChainData
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(chain.emoji)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(chain.theme)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(chain.participantCount)人参与 · \(chain.messageCount)条鼓励")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(chain.completedDate)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.warmGlow)
                        Text("已完成")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.safeGreen)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - ViewModel
@MainActor
final class EncourageMuseumViewModel: ObservableObject {
    @Published var totalKindnessCount: Int = 37
    @Published var chainsInitiated: Int = 8
    @Published var chainsJoined: Int = 12
    @Published var peopleReached: Int = 246
    @Published var badges: [KindnessBadge] = []
    @Published var completedChains: [CompletedChainData] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        badges = [
            KindnessBadge(id: "b1", name: "初次温暖", icon: "hand.wave.fill", color: AppTheme.warmGlow, isUnlocked: true, unlockDate: "2026-06-01"),
            KindnessBadge(id: "b2", name: "温暖新手", icon: "star.fill", color: AppTheme.warmGlow, isUnlocked: true, unlockDate: "2026-06-05"),
            KindnessBadge(id: "b3", name: "鼓励达人", icon: "flame.fill", color: AppTheme.vibrantOrange, isUnlocked: false, unlockDate: nil),
            KindnessBadge(id: "b4", name: "共鸣使者", icon: "waveform.circle.fill", color: AppTheme.primary, isUnlocked: true, unlockDate: "2026-06-10"),
            KindnessBadge(id: "b5", name: "守护天使", icon: "heart.fill", color: AppTheme.roseGold, isUnlocked: false, unlockDate: nil),
            KindnessBadge(id: "b6", name: "7天坚持", icon: "7.circle.fill", color: AppTheme.safeGreen, isUnlocked: true, unlockDate: "2026-06-07"),
            KindnessBadge(id: "b7", name: "善意传播者", icon: "sparkles", color: AppTheme.roseGold, isUnlocked: false, unlockDate: nil),
            KindnessBadge(id: "b8", name: "深夜守护", icon: "moon.stars.fill", color: AppTheme.softPurple, isUnlocked: true, unlockDate: "2026-06-12"),
            KindnessBadge(id: "b9", name: "温暖大使", icon: "crown.fill", color: AppTheme.primary, isUnlocked: false, unlockDate: nil),
        ]
        
        completedChains = [
            CompletedChainData(
                id: "c1",
                theme: "给备考的你加油",
                emoji: "📚",
                participantCount: 28,
                messageCount: 34,
                completedDate: "2026-06-15"
            ),
            CompletedChainData(
                id: "c2",
                theme: "失眠夜的陪伴",
                emoji: "🌙",
                participantCount: 15,
                messageCount: 19,
                completedDate: "2026-06-12"
            ),
            CompletedChainData(
                id: "c3",
                theme: "周一综合征互助",
                emoji: "☕️",
                participantCount: 42,
                messageCount: 50,
                completedDate: "2026-06-08"
            ),
        ]
    }
}

// MARK: - Data Models
struct KindnessBadge: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let unlockDate: String?
}

struct CompletedChainData: Identifiable {
    let id: String
    let theme: String
    let emoji: String
    let participantCount: Int
    let messageCount: Int
    let completedDate: String
}

#Preview {
    NavigationStack {
        EncourageMuseumView()
    }
}
