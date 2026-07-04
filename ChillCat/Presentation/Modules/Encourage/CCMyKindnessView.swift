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
    @Environment(CCAppCoordinator.self) private var coordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // 个人统计
            personalStatsBar
            
            // 分段选择器
            segmentPicker
            
            // 内容列表
            ScrollView {
                LazyVStack(spacing: XuanSpacing.md) {
                    switch selectedSegment {
                    case .participated:
                        participatedChainsList
                    case .initiated:
                        initiatedChainsList
                    }
                }
                .padding(XuanSpacing.lg)
            }
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("我的善意")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Stats Bar
    private var personalStatsBar: some View {
        VStack(spacing: XuanSpacing.md) {
            // 善意传递动画区域
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.xuanApricotDark.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 2) {
                    Text("\(viewModel.totalKindness)")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanApricotDark)
                    
                    Text("份善意")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
            
            HStack(spacing: XuanSpacing.xl2) {
                StatPill(icon: "arrow.up.heart.fill", value: "\(viewModel.sentCount)", label: "发出", color: Color.xuanApricotDark)
                StatPill(icon: "arrow.down.heart.fill", value: "\(viewModel.receivedCount)", label: "收到", color: Color.xuanPink)
                StatPill(icon: "person.2.fill", value: "\(viewModel.connectedPeople)", label: "连接", color: Color.xuanApricot)
            }
        }
        .padding(.vertical, XuanSpacing.lg)
        .padding(.horizontal, XuanSpacing.lg)
        .background(Color.xuanSurface)
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
                    VStack(spacing: XuanSpacing.sm) {
                        Text(segment.title)
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(
                                selectedSegment == segment
                                    ? Color.xuanApricot
                                    : Color.xuanTextTertiary
                            )
                        
                        Rectangle()
                            .fill(
                                selectedSegment == segment
                                    ? Color.xuanApricot
                                    : Color.clear
                            )
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.top, XuanSpacing.md)
        .background(Color.xuanSurface)
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
                    action: { coordinator.navigate(to: .encourageChain) }
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
                    action: { coordinator.navigate(to: .encourageChain) }
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
        VStack(spacing: XuanSpacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(value)
                    .font(XuanFont.h3)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextTertiary)
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
            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                HStack {
                    Text(chain.emoji)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chain.theme)
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanTextPrimary)
                        
                        Text("\(chain.participantCount)人参与 · 最后更新 \(chain.lastUpdated)")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(chain.statusText)
                            .font(XuanFont.caption)
                            .foregroundColor(chain.statusColor)
                            .padding(.horizontal, XuanSpacing.sm)
                            .padding(.vertical, 2)
                            .background(chain.statusColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                if isAnimating {
                    HStack(spacing: XuanSpacing.sm) {
                        ForEach(0..<5) { i in
                            Image("resonance_like")
                                .font(.system(size: 12))
                                .foregroundColor(Color.xuanApricotDark)
                                .offset(y: isAnimating ? -20 : 0)
                                .opacity(isAnimating ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.6).delay(Double(i) * 0.1),
                                    value: isAnimating
                                )
                        }
                        
                        Text("传递中...")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanApricotDark)
                    }
                    .padding(.top, XuanSpacing.xs)
                }
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(isAnimating ? Color.xuanApricotDark.opacity(0.3) : Color.clear, lineWidth: 1)
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
            sentCount = myChains.reduce(0) { $0 + ($1.links?.count ?? 0) }
            connectedPeople = myChains.reduce(0) { $0 + Int($1.participantCount ?? 0) }
        } catch {
            participatedChains = []
            initiatedChains = []
            errorMessage = "数据加载失败"
            print("⚠️ [MyKindness] API failed: \(error)")
        }
        isLoading = false
    }
    
    private static func mapToMyChain(_ chain: CCXuanAPI.ChainResponse) -> MyChainData {
        let links = chain.links ?? []
        return MyChainData(
            id: String(chain.chainId ?? 0),
            theme: (links.first?.content ?? "鼓励链").prefix(15) + "…",
            emoji: "💛",
            participantCount: Int(chain.participantCount ?? 0),
            lastUpdated: links.last?.createdAt ?? "",
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
        case .active: return Color.xuanSuccess
        case .completed: return Color.xuanTextTertiary
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
