import SwiftUI

/// 我的鼓励链 — §2.4 个人页面
struct CCMyEncourageChainsView: View {
    @State private var viewModel = CCEncourageChainViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        Group {
            if viewModel.isLoadingMyChains {
                CCLoadingView(message: "加载中…")
            } else if viewModel.myChains.isEmpty {
                CCEmptyStateView(
                    title: "还没有参与过鼓励链",
                    message: "去鼓励链写下你的第一句鼓励吧",
                    imageName: "flame.fill",
                    actionTitle: "去鼓励链"
                ) {
                    coordinator.navigate(to: .encourageChain)
                }
            } else {
                ScrollView {
                    VStack(spacing: theme.spacingSM) {
                        ForEach(viewModel.myChains) { chain in
                            chainCard(chain)
                        }
                    }
                    .padding()
                }
                .background(theme.background)
            }
        }
        .navigationTitle("我的鼓励链")
        .task { await viewModel.loadMyChains() }
    }

    private func chainCard(_ chain: ChainSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🌟 鼓励链")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.warm)
                Spacer()
                Text("\(chain.linkCount) 条接力")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
            }

            Text(chain.firstMessage)
                .font(.system(size: 15))
                .foregroundColor(theme.textPrimary)
                .lineSpacing(4)
                .lineLimit(3)

            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                Text("\(chain.participantCount) 人参与")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)

                Spacer()

                Button(action: {
                    Task {
                        await viewModel.loadChain(id: Int64(chain.chainId) ?? 0)
                    }
                }) {
                    Text("查看详情")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }
}
