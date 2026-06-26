import Combine
import SwiftUI

// MARK: - MyKindnessView v3.0
/// 我的善意页面
/// 我参与/发起的链 + 动态传递动画

struct MyKindnessView: View {
    @StateObject private var viewModel = MyKindnessViewModel()
    @State private var selectedSegment: KindnessSegment = .participated
    @State private var showPassAnimation = false
    @State private var animatingChainId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // 个人统计
            personalStatsBar
            
            // 分段选择器
            segmentPicker
            
            // 内容列表
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    switch selectedSegment {
                    case .participated:
                        participatedChainsList
                    case .initiated:
                        initiatedChainsList
                    }
                }
                .padding(AppSpacing.lg)
            }
        }
        .background(AppTheme.background)
        .navigationTitle("我的善意")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Stats Bar
    private var personalStatsBar: some View {
        VStack(spacing: AppSpacing.md) {
            // 善意传递动画区域
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.warmGlow.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 2) {
                    Text("\(viewModel.totalKindness)")
                        .font(AppFont.largeTitle)
                        .foregroundColor(AppTheme.warmGlow)
                    
                    Text("份善意")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            HStack(spacing: AppSpacing.xxl) {
                StatPill(icon: "arrow.up.heart.fill", value: "\(viewModel.sentCount)", label: "发出", color: AppTheme.warmGlow)
                StatPill(icon: "arrow.down.heart.fill", value: "\(viewModel.receivedCount)", label: "收到", color: AppTheme.roseGold)
                StatPill(icon: "person.2.fill", value: "\(viewModel.connectedPeople)", label: "连接", color: AppTheme.primary)
            }
        }
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.lg)
        .background(AppTheme.surface)
    }
    
    // MARK: - Segment Picker
    private var segmentPicker: some View {
        HStack(spacing: 0) {
            ForEach(KindnessSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = segment
                    }
                } label: {
                    VStack(spacing: AppSpacing.sm) {
                        Text(segment.title)
                            .font(AppFont.bodyBold)
                            .foregroundColor(
                                selectedSegment == segment
                                    ? AppTheme.primary
                                    : AppTheme.textTertiary
                            )
                        
                        Rectangle()
                            .fill(
                                selectedSegment == segment
                                    ? AppTheme.primary
                                    : Color.clear
                            )
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .background(AppTheme.surface)
    }
    
    // MARK: - Participated Chains
    private var participatedChainsList: some View {
        Group {
            if viewModel.participatedChains.isEmpty {
                CCEmptyStateView(
                    title: "暂无记录",
                    message: "还没有参与任何鼓励链\n去发现页找到温暖的链吧",
                    imageName: "heart.text.clipboard",
                    actionTitle: "去发现",
                    action: {}
                )
                .padding(.top, 40)
            } else {
                ForEach(viewModel.participatedChains) { chain in
                    MyChainCard(
                        chain: chain,
                        isAnimating: animatingChainId == chain.id,
                        onTap: {
                            triggerPassAnimation(chain.id)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Initiated Chains
    private var initiatedChainsList: some View {
        Group {
            if viewModel.initiatedChains.isEmpty {
                CCEmptyStateView(
                    title: "暂无记录",
                    message: "还没有发起过鼓励链\n发起第一条温暖的链吧",
                    imageName: "heart.text.clipboard",
                    actionTitle: "发起新链",
                    action: {}
                )
                .padding(.top, 40)
            } else {
                ForEach(viewModel.initiatedChains) { chain in
                    MyChainCard(
                        chain: chain,
                        isAnimating: animatingChainId == chain.id,
                        onTap: {
                            triggerPassAnimation(chain.id)
                        }
                    )
                }
            }
        }
    }
    
    private func triggerPassAnimation(_ chainId: String) {
        animatingChainId = chainId
        showPassAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animatingChainId = nil
            showPassAnimation = false
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(value)
                    .font(AppFont.title3)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(AppFont.caption2)
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}

// MARK: - My Chain Card
struct MyChainCard: View {
    let chain: MyChainData
    let isAnimating: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(chain.emoji)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chain.theme)
                            .font(AppFont.bodyBold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("\(chain.participantCount)人参与 · 最后更新 \(chain.lastUpdated)")
                            .font(AppFont.caption2)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(chain.statusText)
                            .font(AppFont.caption2)
                            .foregroundColor(chain.statusColor)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 2)
                            .background(chain.statusColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                if isAnimating {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<5) { i in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.warmGlow)
                                .offset(y: isAnimating ? -20 : 0)
                                .opacity(isAnimating ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.6).delay(Double(i) * 0.1),
                                    value: isAnimating
                                )
                        }
                        
                        Text("传递中...")
                            .font(AppFont.caption2)
                            .foregroundColor(AppTheme.warmGlow)
                    }
                    .padding(.top, AppSpacing.xs)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(isAnimating ? AppTheme.warmGlow.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Segment Enum
enum KindnessSegment: CaseIterable {
    case participated
    case initiated
    
    var title: String {
        switch self {
        case .participated: return "我参与的"
        case .initiated: return "我发起的"
        }
    }
}

// MARK: - ViewModel
@MainActor
final class MyKindnessViewModel: ObservableObject {
    @Published var totalKindness: Int = 0
    @Published var sentCount: Int = 0
    @Published var receivedCount: Int = 0
    @Published var connectedPeople: Int = 0
    @Published var participatedChains: [MyChainData] = []
    @Published var initiatedChains: [MyChainData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        Task { await loadData() }
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let myChains = try await CCXuanAPI.getMyChains()
            participatedChains = myChains.map { Self.mapToMyChain($0) }
            initiatedChains = [] // initiated chains not separately returned by getMyChains
            totalKindness = myChains.count
            sentCount = myChains.reduce(0) { $0 + $1.links.count }
            connectedPeople = myChains.reduce(0) { $0 + Int($1.participantCount) }
        } catch {
            participatedChains = []
            initiatedChains = []
            errorMessage = "数据加载失败"
            print("⚠️ [MyKindness] API failed: \(error)")
        }
        isLoading = false
    }
    
    private static func mapToMyChain(_ chain: CCXuanAPI.ChainResponse) -> MyChainData {
        MyChainData(
            id: String(chain.chainId),
            theme: chain.links.first?.content.prefix(15).appending("…") ?? "鼓励链",
            emoji: "💛",
            participantCount: Int(chain.participantCount),
            lastUpdated: chain.links.last?.createdAt ?? "",
            status: .active
        )
    }
}

// MARK: - Data Models
struct MyChainData: Identifiable {
    let id: String
    let theme: String
    let emoji: String
    let participantCount: Int
    let lastUpdated: String
    let status: ChainStatus
    
    var statusText: String {
        switch status {
        case .active: return "进行中"
        case .completed: return "已完成"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .active: return AppTheme.safeGreen
        case .completed: return AppTheme.textTertiary
        }
    }
}

enum ChainStatus {
    case active
    case completed
}

#Preview {
    NavigationStack {
        MyKindnessView()
    }
}
