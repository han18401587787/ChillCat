import Combine
import SwiftUI

// MARK: - EncourageMuseumView v3.0
/// 鼓励链博物馆
/// 已完成链展示 + 里程碑(10/50/100) + 善意勋章

struct EncourageMuseumView: View {
    @StateObject private var viewModel = EncourageMuseumViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl) {
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
            .padding(.horizontal, XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("善意博物馆")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: XuanSpacing.lg) {
            Text("🏛️")
                .font(.system(size: 48))
            
            Text("你已传递 \(viewModel.totalKindnessCount) 份善意")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            HStack(spacing: XuanSpacing.xl2) {
                StatItem(value: "\(viewModel.chainsInitiated)", label: "发起链", color: Color.xuanApricot)
                StatItem(value: "\(viewModel.chainsJoined)", label: "参与链", color: Color.xuanApricotDark)
                StatItem(value: "\(viewModel.peopleReached)", label: "触达人数", color: Color.xuanPink)
            }
        }
        .padding(XuanSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color(hex: "FDF0D5"), Color.xuanPink.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }
    
    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("里程碑")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            VStack(spacing: XuanSpacing.md) {
                MilestoneRow(
                    icon: "star.fill",
                    title: "温暖新手",
                    subtitle: "完成10次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 10.0,
                    isCompleted: viewModel.totalKindnessCount >= 10,
                    color: Color.xuanApricotDark
                )
                
                MilestoneRow(
                    icon: "sparkles",
                    title: "善意传播者",
                    subtitle: "完成50次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 50.0,
                    isCompleted: viewModel.totalKindnessCount >= 50,
                    color: Color.xuanPink
                )
                
                MilestoneRow(
                    icon: "crown.fill",
                    title: "温暖大使",
                    subtitle: "完成100次鼓励传递",
                    progress: Double(viewModel.totalKindnessCount) / 100.0,
                    isCompleted: viewModel.totalKindnessCount >= 100,
                    color: Color.xuanApricot
                )
            }
            .sectionGroup()
        }
    }
    
    // MARK: - Badges
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("善意勋章")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: XuanSpacing.md) {
                ForEach(viewModel.badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }
    
    // MARK: - Completed Chains
    private var completedChainsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("已完成的链")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            VStack(spacing: XuanSpacing.md) {
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
        VStack(spacing: XuanSpacing.xs) {
            Text(value)
                .font(XuanFont.h2)
                .foregroundColor(color)
            
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
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
        HStack(spacing: XuanSpacing.md) {
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
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)
                
                Text(subtitle)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
                
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
        VStack(spacing: XuanSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        badge.isUnlocked
                            ? badge.color.opacity(0.15)
                            : Color.xuanSurface
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 28))
                    .foregroundColor(badge.isUnlocked ? badge.color : Color.xuanTextTertiary)
                    .opacity(badge.isUnlocked ? 1.0 : 0.4)
            }
            
            Text(badge.name)
                .font(XuanFont.caption)
                .foregroundColor(
                    badge.isUnlocked ? Color.xuanTextPrimary : Color.xuanTextTertiary
                )
                .multilineTextAlignment(.center)
            
            if badge.isUnlocked, let date = badge.unlockDate {
                Text(date)
                    .font(.system(size: 10))
                    .foregroundColor(Color.xuanTextTertiary)
            }
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Completed Chain Row
struct CompletedChainRow: View {
    let chain: CompletedChainData
    
    var body: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text(chain.emoji)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(chain.theme)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("\(chain.participantCount)人参与 · \(chain.messageCount)条鼓励")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(chain.completedDate)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.xuanApricotDark)
                        Text("已完成")
                            .font(.system(size: 10))
                            .foregroundColor(Color.xuanSuccess)
                    }
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - ViewModel
@MainActor
final class EncourageMuseumViewModel: ObservableObject {
    @Published var totalKindnessCount: Int = 0
    @Published var chainsInitiated: Int = 0
    @Published var chainsJoined: Int = 0
    @Published var peopleReached: Int = 0
    @Published var badges: [KindnessBadge] = []
    @Published var completedChains: [CompletedChainData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        Task { await loadData() }
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let chains = try await CCXuanAPI.listChains()
            totalKindnessCount = chains.reduce(0) { $0 + Int($1.participantCount ?? 0) }
            chainsJoined = chains.count
            peopleReached = chains.reduce(0) { $0 + Int($1.participantCount ?? 0) }
            
            completedChains = chains.compactMap { chain in
                guard let lastLink = (chain.links ?? []).last else { return nil }
                return CompletedChainData(
                    id: String(chain.chainId ?? 0),
                    theme: (chain.links?.first?.content ?? "鼓励链").prefix(15).appending("…") ?? "鼓励链",
                    emoji: "💛",
                    participantCount: Int(chain.participantCount ?? 0),
                    messageCount: chain.links?.count ?? 0,
                    completedDate: lastLink.createdAt ?? ""
                )
            }
        } catch {
            completedChains = []
            errorMessage = "数据加载失败"
            print("⚠️ [EncourageMuseum] API failed: \(error)")
        }
        
        // Load badges from achievements
        do {
            let achievements = try await CCXuanAPI.getAchievements()
            badges = achievements.map { vo in
                KindnessBadge(
                    id: String(vo.id),
                    name: vo.name,
                    icon: vo.iconName,
                    color: Color.xuanApricotDark,
                    isUnlocked: vo.isUnlocked,
                    unlockDate: vo.unlockedAt
                )
            }
        } catch {
            print("⚠️ [EncourageMuseum] Achievements API failed: \(error)")
        }
        
        isLoading = false
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
