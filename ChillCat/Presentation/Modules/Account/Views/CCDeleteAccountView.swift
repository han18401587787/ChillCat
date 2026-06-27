import SwiftUI

struct CCDeleteAccountView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var confirmed = false
    @State private var viewModel = CCDeleteAccountViewModel(
        userRepository: CCAppDependencyContainer.shared.container.resolve()
    )

    var body: some View {
        Group {
            if viewModel.isDeleted {
                deletedView
            } else if !confirmed {
                warningView
            } else {
                confirmView
            }
        }
        .background(AppTheme.background).navigationTitle("注销账号")
        .alert("注销失败", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("重试") { Task { await viewModel.deleteAccount() } }
            Button("取消", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Warning
    var warningView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64)).foregroundColor(AppTheme.warmPink)

            Text("绪安 会想念你的。").font(.system(size: 22, weight: .bold))
            Text("随时欢迎回来。").font(.system(size: 16)).foregroundColor(AppTheme.textSecondary)

            VStack(spacing: AppSpacing.sm) {
                warningRow(icon: "exclamationmark.triangle.fill", text: "所有情绪日记与打卡记录将被永久删除")
                warningRow(icon: "person.slash.fill", text: "所有账号数据将从服务器永久删除")
                warningRow(icon: "clock.arrow.circlepath", text: "注销后 7 天内可撤销，逾期数据无法恢复")
                warningRow(icon: "tree.fill", text: "树洞内容与圈子记录将被清除")
            }
            .padding().background(AppTheme.cardBackground).cornerRadius(AppRadius.md)

            Spacer()

            Button(action: { confirmed = true }) {
                Text("确认注销").fontWeight(.semibold).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.crisisRed).cornerRadius(AppRadius.md)
            }.padding(.horizontal)

            Button(action: { coordinator.pop() }) {
                Text("我再想想，先不注销").foregroundColor(AppTheme.primary)
            }.padding(.bottom, AppSpacing.xl)
        }.padding()
    }

    // MARK: - Confirm
    var confirmView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 56)).foregroundColor(AppTheme.crisisRed)

            Text("注销后将永久失去").font(.system(size: 20, weight: .bold))
            Text("所有账号数据将从服务器永久删除，此操作不可撤销。").font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center).padding(.horizontal)

            Button(action: { Task { await viewModel.deleteAccount() } }) {
                if viewModel.isDeleting {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                } else {
                    Text("确认注销").fontWeight(.semibold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                }
            }
            .disabled(viewModel.isDeleting)
            .background(AppTheme.crisisRed).cornerRadius(AppRadius.md).padding(.horizontal)

            Button(action: { confirmed = false }) {
                Text("返回").foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }.padding()
    }

    // MARK: - Deleted
    var deletedView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "leaf.circle.fill").font(.system(size: 64)).foregroundColor(AppTheme.primaryDark)
            Text("绪安 会想念你的。").font(.system(size: 22, weight: .bold))
            Text("随时欢迎回来。").font(.system(size: 16)).foregroundColor(AppTheme.textSecondary)
            Text("7 天内可撤销注销").font(.system(size: 13)).foregroundColor(AppTheme.textMuted)
            Spacer()
            Button(action: { coordinator.isLoggedIn = false }) {
                Text("回到首页").fontWeight(.medium).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.primaryDark).cornerRadius(AppRadius.md)
            }.padding(.horizontal).padding(.bottom, 50)
        }.padding()
    }

    func warningRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(AppTheme.crisisRed).frame(width: 24)
            Text(text).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
    }
}
