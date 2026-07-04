import SwiftUI

/// 我的鼓励链 — §2.4 个人页面
struct CCMyEncourageChainsView: View {
    @State private var viewModel = CCEncourageChainViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

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
                    VStack(spacing: XuanSpacing.sm) {
                        ForEach(viewModel.myChains) { chain in
                            chainCard(chain)
                        }
                    }
                    .padding()
                }
                .background(Color.xuanApricotBg)
            }
        }
        .navigationTitle("我的鼓励链")
        .task { await viewModel.loadMyChains() }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessageMyChains {
                HStack {
                    Image("alert_warn")
                        .foregroundColor(Color.xuanDanger)
                    Text(error)
                        .foregroundColor(Color.xuanDanger)
                }
                .font(.system(size: 14))
                .padding()
                .background(Color.xuanDanger.opacity(0.08))
                .cornerRadius(XuanRadius.sm)
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.errorMessageMyChains)
    }

    private func chainCard(_ chain: ChainSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🌟 鼓励链")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.xuanApricotDark)
                Spacer()
                Text("\(chain.linkCount) 条接力")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text(chain.firstMessage)
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(4)
                .lineLimit(3)

            HStack {
                Image("resonance_people")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanTextTertiary)
                Text("\(chain.participantCount) 人参与")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanTextTertiary)

                Spacer()

                Button(action: {
                    guard let id = Int64(chain.chainId) else { return }
                    coordinator.navigate(to: .encourageChainDetail(chainId: id))
                }) {
                    Text("查看详情")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.xuanApricot)
                }
            }
        }
        .padding()
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }
}
