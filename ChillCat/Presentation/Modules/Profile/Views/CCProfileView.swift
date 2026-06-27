import SwiftUI

// MARK: - 个人中心 v3.0 (Ardot Design)
/// 对照设计图像素级还原
/// 包含：用户信息卡片、统计数据、功能入口列表、设置/退出

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
        .background(AppTheme.background)
        .navigationTitle("个人中心")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadProfile() }
    }

    // MARK: - 主内容
    private var content: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                // 用户信息卡片
                userInfoCard

                // 统计概览
                statsOverview

                // 心光会员大卡片
                vipBannerCard

                // 功能入口
                featureSection

                // 底部操作
                bottomActions
            }
            .padding(AppSpacing.lg)
        }
    }

    // MARK: - 用户信息卡片
    private var userInfoCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // 头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accentMint, AppTheme.accentMintDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayName)
                    .font(AppFont.title2)
                    .foregroundColor(AppTheme.textPrimary)

                Text(daysSinceJoinedText)
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // 编辑按钮
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 统计概览
    private var statsOverview: some View {
        HStack(spacing: AppSpacing.sm) {
            statItem(value: "\(viewModel.totalCheckins)", label: "累计打卡", icon: "checkmark.circle.fill", color: AppTheme.accentMint)
            statItem(value: "\(viewModel.streakDays)", label: "连续天数", icon: "flame.fill", color: AppTheme.warmGlow)
            statItem(value: "\(viewModel.resonanceCount)", label: "共鸣次数", icon: "heart.fill", color: AppTheme.warmPink)
        }
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(AppFont.caption2)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 心光会员大卡片
    private var vipBannerCard: some View {
        Button(action: { coordinator.navigate(to: .vipCenter) }) {
            HStack(spacing: AppSpacing.lg) {
                // 左侧图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 48, height: 48)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("心光会员")
                        .font(AppFont.title3)
                        .foregroundColor(.white)
                    Text("解锁更多治愈功能")
                        .font(AppFont.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text("立即开通")
                    .font(AppFont.footnote.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(AppRadius.full)
            }
            .padding(AppSpacing.lg)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "D4A882"),
                        Color(hex: "E8C4A3"),
                        Color(hex: "F2DBC9")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppRadius.lg)
            .shadow(color: Color(hex: "D4A882").opacity(0.25), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    private var featureSection: some View {
        VStack(spacing: AppSpacing.sm) {
            featureRow(
                icon: "crown.fill",
                title: "心光会员",
                subtitle: "解锁更多治愈功能",
                iconColor: Color(hex: "D4A882"),
                action: { coordinator.navigate(to: .vipCenter) }
            )

            featureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "情绪趋势",
                subtitle: "查看情绪变化与洞察",
                iconColor: AppTheme.accentMint,
                action: { coordinator.navigate(to: .trends) }
            )

            featureRow(
                icon: "heart.text.square",
                title: "治愈记录",
                subtitle: "冥想/稳情练习记录",
                iconColor: AppTheme.warmPurple,
                action: { coordinator.navigate(to: .growthArchive) }
            )

            featureRow(
                icon: "envelope.fill",
                title: "感谢信",
                subtitle: "来自绪安的温暖信件",
                iconColor: AppTheme.warmPink,
                action: { coordinator.navigate(to: .journal) }
            )

            featureRow(
                icon: "lock.shield.fill",
                title: "隐私设置",
                subtitle: "管理数据与隐私偏好",
                iconColor: AppTheme.info,
                action: { coordinator.navigate(to: .privacy) }
            )
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 底部操作
    private var bottomActions: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: { coordinator.navigate(to: .settings) }) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(AppTheme.surface)
                            .frame(width: 40, height: 40)

                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Text("设置")
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.lg)
            }
            .buttonStyle(.plain)

            Button(role: .destructive, action: {
                Task {
                    await viewModel.logout()
                    coordinator.isLoggedIn = false
                }
            }) {
                HStack {
                    Spacer()
                    Text("退出登录")
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.error)
                    Spacer()
                }
                .padding(.vertical, AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.lg)
            }
        }
    }

    // MARK: - 辅助方法
    private var daysSinceJoinedText: String {
        guard let createdAt = viewModel.user?.createdAt else { return "感谢你的陪伴" }
        let days = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return "已陪伴你 \(days) 天"
    }
}
