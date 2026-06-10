import SwiftUI

struct CCProfileView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCProfileViewModel(
        profileUseCase: CCAppDependencyContainer.shared.container.resolve()
    )

    var body: some View {
        Group {
            if viewModel.isLoading {
                CCLoadingView(message: "加载中...")
            } else if let errorMessage = viewModel.errorMessage {
                CCErrorView(
                    error: NSError(domain: "profile", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]),
                    retryAction: { await viewModel.loadProfile() }
                )
            } else if viewModel.user == nil {
                CCEmptyStateView(
                    title: "暂无数据",
                    message: "未能加载用户信息",
                    imageName: "person.fill.questionmark",
                    actionTitle: "重试",
                    action: { await viewModel.loadProfile() }
                )
            } else {
                content
            }
        }
        .navigationTitle("我的")
        .task { await viewModel.loadProfile() }
    }

    private var content: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 52)).foregroundColor(Color(hex: "5A7A8A"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.displayName).font(.system(size: 20, weight: .semibold))
                        Text(daysSinceJoinedText).font(.system(size: 14)).foregroundColor(.secondary)
                    }
                }.padding(.vertical, 8)
            }

            Section {
                Button(action: { coordinator.navigate(to: .vipCenter) }) {
                    Label("会员中心", systemImage: "crown.fill").foregroundColor(Color(hex: "8B6F47"))
                }
            }

            Section {
                Button(action: { coordinator.navigate(to: .settings) }) {
                    Label("设置", systemImage: "gearshape.fill").foregroundColor(.primary)
                }
            }

            Section {
                Button(role: .destructive, action: {
                    Task {
                        await viewModel.logout()
                        coordinator.isLoggedIn = false
                    }
                }) {
                    HStack { Spacer(); Text("退出登录"); Spacer() }
                }
            }
        }
    }

    private var daysSinceJoinedText: String {
        guard let createdAt = viewModel.user?.createdAt else { return "" }
        let days = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return "已陪伴你 \(days) 天"
    }
}
