//
//  CCSettingsView.swift
//  绪安 - 设置页面 (严格对照设计稿 page_47 像素级还原)
//
//  设计稿来源: /workspace/design_pages/page_47.png

import SwiftUI
import KeychainAccess

struct CCSettingsView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(CCThemeManager.self) private var themeManager
    @State private var viewModel = CCSettingsViewModel()
    @State private var showLogoutConfirm = false
    @State private var profileViewModel = CCProfileViewModel(
        profileUseCase: CCAppDependencyContainer.shared.container.resolve()
    )

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 账号与安全
                sectionView("账号与安全") {
                    settingsRow(icon: "person.fill", title: "账号信息", color: Color.xuanApricot) {}
                        .accessibilityIdentifier("settings_account_info")
                    settingsRow(icon: "lock.fill", title: "安全设置", color: Color.xuanMint) {}
                        .accessibilityIdentifier("settings_security")
                    settingsRow(icon: "key.fill", title: "密码管理", color: Color.xuanInfo) {}
                        .accessibilityIdentifier("settings_password")
                }

                // 消息通知
                sectionView("消息通知") {
                    settingsRow(icon: "bell.fill", title: "消息推送", color: Color.xuanPink) {
                        // toggle handled inline
                    } trailing: {
                        AnyView(Toggle("", isOn: Binding(
                            get: { viewModel.notificationsEnabled },
                            set: { viewModel.notificationsEnabled = $0 }
                        ))
                        .labelsHidden()
                        .accessibilityIdentifier("settings_notifications_toggle"))
                    }
                    .accessibilityIdentifier("settings_notifications")
                    settingsRow(icon: "moon.fill", title: "勿扰模式", color: Color(hex: "A085C6")) {}
                        .accessibilityIdentifier("settings_dnd")
                }

                // 隐私设置
                sectionView("隐私设置") {
                    settingsRow(icon: "hand.raised.fill", title: "隐私保护", color: Color.xuanInfo) {
                        coordinator.navigate(to: .privacy)
                    }
                    .accessibilityIdentifier("settings_privacy")
                    settingsRow(icon: "eye.slash.fill", title: "匿名保护", color: Color.xuanTextTertiary) {}
                        .accessibilityIdentifier("settings_anonymous")
                }

                // 外观
                sectionView("外观") {
                    Button(action: { themeManager.toggleTheme() }) {
                        HStack(spacing: XuanSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: XuanRadius.sm)
                                    .fill(Color.xuanApricot.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                CCIconMapper.image(for: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.xuanApricot)
                            }
                            Text("深色模式")
                                .font(XuanFont.bodyL)
                                .foregroundColor(Color.xuanTextPrimary)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in themeManager.toggleTheme() }
                            ))
                            .labelsHidden()
                            .accessibilityIdentifier("settings_dark_mode_toggle")
                        }
                        .padding(XuanSpacing.md)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings_dark_mode")
                }

                // 关于
                sectionView("关于") {
                    settingsRow(icon: "info.circle.fill", title: "版本信息", color: Color.xuanTextTertiary) {} trailing: {
                        AnyView(Text("v3.0.0")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextTertiary))
                    }
                    .accessibilityIdentifier("settings_version")
                    settingsRow(icon: "doc.text.fill", title: "用户协议", color: Color.xuanTextSecondary) {
                        coordinator.navigate(to: .userAgreement)
                    }
                    .accessibilityIdentifier("settings_user_agreement")
                    settingsRow(icon: "shield.fill", title: "隐私政策", color: Color.xuanTextSecondary) {
                        coordinator.navigate(to: .privacyPolicy)
                    }
                    .accessibilityIdentifier("settings_privacy_policy")
                    settingsRow(icon: "questionmark.circle.fill", title: "常见问题", color: Color.xuanTextSecondary) {
                        coordinator.navigate(to: .faq)
                    }
                    .accessibilityIdentifier("settings_faq")
                    settingsRow(icon: "envelope.fill", title: "意见反馈", color: Color.xuanTextSecondary) {
                        coordinator.navigate(to: .feedback)
                    }
                    .accessibilityIdentifier("settings_feedback")
                }

                // 数据管理
                sectionView("数据管理") {
                    settingsRow(icon: "externaldrive.fill", title: "数据管理", color: Color.xuanInfo) {
                        coordinator.navigate(to: .dataManagement)
                    }
                    .accessibilityIdentifier("settings_data_management")
                    Button(action: { coordinator.navigate(to: .deleteAccount) }) {
                        HStack(spacing: XuanSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: XuanRadius.sm)
                                    .fill(Color.xuanDanger.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image("common_delete")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.xuanDanger)
                            }
                            Text("注销账号")
                                .font(XuanFont.bodyL)
                                .foregroundColor(Color.xuanDanger)
                            Spacer()
                        }
                        .padding(XuanSpacing.md)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings_delete_account")
                }

                // 退出登录
                Button(action: {
                    showLogoutConfirm = true
                }) {
                    HStack(spacing: XuanSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: XuanRadius.sm)
                                .fill(Color.xuanDanger.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Image("profile_logout")
                                .font(.system(size: 16))
                                .foregroundColor(Color.xuanDanger)
                        }
                        Text("退出登录")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanDanger)
                        Spacer()
                    }
                    .padding(XuanSpacing.md)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.md)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("settings_logout")
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .alert("退出登录", isPresented: $showLogoutConfirm) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                Task {
                    await profileViewModel.logout()
                    // 清除 token
                    let keychain = Keychain(service: "app.xuanpeace.token")
                    try? keychain.remove("access_token")
                    try? keychain.remove("refresh_token")
                    // 重置登录状态
                    coordinator.isLoggedIn = false
                    coordinator.hasSeenWelcome = true
                    coordinator.popToRoot()
                }
            }
        } message: {
            Text("确定要退出登录吗？退出后需要重新登录")
        }
    }

    // MARK: - Section
    private func sectionView<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            Text(title)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
                .padding(.leading, 4)

            VStack(spacing: 1) {
                content()
            }
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
            .xuanCardShadow()
        }
    }

    // MARK: - Row
    @ViewBuilder
    private func settingsRow(icon: String, title: String, color: Color, action: @escaping () -> Void, trailing: (() -> AnyView)? = nil) -> some View {
        Button(action: action) {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.sm)
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    CCIconMapper.image(for: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                if let trailing = trailing {
                    trailing()
                } else {
                    Image("common_more")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
            .padding(XuanSpacing.md)
        }
        .buttonStyle(.plain)
        Divider()
            .padding(.leading, 52)
    }
}
