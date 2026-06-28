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
            } else {
                // 未登录也正常展示页面，用默认值
                content
            }
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("个人中心")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadProfile() }
    }

    // MARK: - 主内容
    private var content: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
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
            .padding(XuanSpacing.lg)
        }
    }

    // MARK: - 用户信息卡片
    private var userInfoCard: some View {
        Button(action: {
            // 未登录时点击跳转登录页
            if viewModel.user == nil {
                coordinator.isLoggedIn = false
            }
        }) {
            HStack(spacing: XuanSpacing.lg) {
                // 头像
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.xuanMint, Color.xuanMintDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: viewModel.user == nil ? "person.circle.fill" : "leaf.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(viewModel.displayName)
                            .font(XuanFont.h2)
                            .foregroundColor(Color.xuanTextPrimary)
                        if viewModel.user == nil {
                            Text("点击登录")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanApricot)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.xuanApricot.opacity(0.12))
                                .cornerRadius(XuanRadius.sm)
                        }
                    }

                    Text(daysSinceJoinedText)
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

            // 编辑按钮
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.xuanTextTertiary)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .buttonStyle(.plain)
        .xuanCardShadow()
    }

    // MARK: - 统计概览
    private var statsOverview: some View {
        HStack(spacing: XuanSpacing.sm) {
            statItem(value: "\(viewModel.totalCheckins)", label: "累计打卡", icon: "checkmark.circle.fill", color: Color.xuanMint)
            statItem(value: "\(viewModel.streakDays)", label: "连续天数", icon: "flame.fill", color: Color.xuanApricotDark)
            statItem(value: "\(viewModel.resonanceCount)", label: "共鸣次数", icon: "heart.fill", color: Color.xuanPink)
        }
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: XuanSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: XuanRadius.md)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.xuanTextPrimary)

            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 心光会员大卡片
    private var vipBannerCard: some View {
        Button(action: { coordinator.navigate(to: .vipCenter) }) {
            HStack(spacing: XuanSpacing.lg) {
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
                        .font(XuanFont.h3)
                        .foregroundColor(.white)
                    Text("解锁更多治愈功能")
                        .font(XuanFont.bodyS)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text("立即开通")
                    .font(XuanFont.bodyS.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(XuanRadius.full)
            }
            .padding(XuanSpacing.lg)
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
            .cornerRadius(XuanRadius.lg)
            .shadow(color: Color(hex: "D4A882").opacity(0.25), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    private var featureSection: some View {
        VStack(spacing: XuanSpacing.sm) {
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
                iconColor: Color.xuanMint,
                action: { coordinator.navigate(to: .trends) }
            )

            featureRow(
                icon: "heart.text.square",
                title: "治愈记录",
                subtitle: "冥想/稳情练习记录",
                iconColor: Color(hex: "A085C6"),
                action: { coordinator.navigate(to: .growthArchive) }
            )

            featureRow(
                icon: "envelope.fill",
                title: "感谢信",
                subtitle: "来自绪安的温暖信件",
                iconColor: Color.xuanPink,
                action: { coordinator.navigate(to: .journal) }
            )

            featureRow(
                icon: "lock.shield.fill",
                title: "隐私设置",
                subtitle: "管理数据与隐私偏好",
                iconColor: Color.xuanInfo,
                action: { coordinator.navigate(to: .privacy) }
            )
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.sm)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(subtitle)
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.xuanTextTertiary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 底部操作
    private var bottomActions: some View {
        VStack(spacing: XuanSpacing.sm) {
            Button(action: { coordinator.navigate(to: .settings) }) {
                HStack(spacing: XuanSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: XuanRadius.sm)
                            .fill(Color.xuanSurface)
                            .frame(width: 40, height: 40)

                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.xuanTextSecondary)
                    }

                    Text("设置")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.xuanTextTertiary)
                }
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.lg)
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
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanDanger)
                    Spacer()
                }
                .padding(.vertical, XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.lg)
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
