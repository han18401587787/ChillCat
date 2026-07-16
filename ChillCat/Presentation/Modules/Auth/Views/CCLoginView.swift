//
//  CCLoginView.swift
//  绪安 - 登录页面 (严格对照设计稿 page_46 像素级还原)
//
//  设计稿来源: /workspace/design_pages/page_46.png
//  布局：Logo → 标题 → 手机号输入 → 验证码输入 → 登录按钮 → 微信/Apple登录 → 协议

import SwiftUI

struct CCLoginView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCLoginViewModel(
        loginUseCase: CCAppDependencyContainer.shared.container.resolve(),
        userRepository: CCAppDependencyContainer.shared.container.resolve()
    )
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var isSendingCode: Bool = false
    @State private var countdown: Int = 0
    @State private var showSocialLoginToast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: XuanSpacing.xl3) {
                    Spacer().frame(height: 60)

                    // Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.xuanMint, Color.xuanApricot],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image("healing_meditate")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }

                    // 标题
                    VStack(spacing: XuanSpacing.sm) {
                        Text("绪安")
                            .font(XuanFont.h1)
                            .foregroundColor(Color.xuanTextPrimary)

                        Text("你的情绪治愈伙伴")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanTextSecondary)
                    }

                    // 输入区
                    VStack(spacing: XuanSpacing.md) {
                        // 手机号
                        HStack(spacing: XuanSpacing.sm) {
                            Text("+86")
                                .font(XuanFont.bodyL)
                                .foregroundColor(Color.xuanTextPrimary)
                                .padding(.leading, XuanSpacing.md)

                            Rectangle()
                                .fill(Color.xuanBorder)
                                .frame(width: 1, height: 24)

                            TextField("请输入手机号", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .font(XuanFont.bodyL)
                        }
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: XuanRadius.md)
                                .stroke(Color.xuanBorder, lineWidth: 1)
                        )
                        .accessibilityIdentifier("login_phone_field")

                        // 验证码
                        HStack(spacing: XuanSpacing.sm) {
                            TextField("请输入验证码", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .font(XuanFont.bodyL)
                                .padding(.leading, XuanSpacing.md)
                                .accessibilityIdentifier("login_code_field")

                            Button(action: {
                                sendVerificationCode()
                            }) {
                                Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                    .font(XuanFont.bodyS)
                                    .foregroundColor(countdown > 0 ? Color.xuanTextTertiary : Color.xuanApricot)
                                    .padding(.horizontal, XuanSpacing.md)
                                    .padding(.vertical, XuanSpacing.sm)
                            }
                            .disabled(countdown > 0 || phoneNumber.count < 11)
                            .accessibilityIdentifier("login_send_code")
                        }
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanWhite)
                        .cornerRadius(XuanRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: XuanRadius.md)
                                .stroke(Color.xuanBorder, lineWidth: 1)
                        )
                    }

                    // 登录按钮
                    Button(action: {
                        Task {
                            viewModel.username = phoneNumber
                            viewModel.password = verificationCode
                            await viewModel.submit()
                        }
                    }) {
                        Text("登录")
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                phoneNumber.count >= 11 && verificationCode.count >= 4
                                    ? Color.xuanApricot
                                    : Color.xuanApricot.opacity(0.4)
                            )
                            .cornerRadius(XuanRadius.md)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .disabled(phoneNumber.count < 11 || verificationCode.count < 4)
                    .accessibilityIdentifier("login_submit_button")

                    // 其他登录方式
                    VStack(spacing: XuanSpacing.lg) {
                        HStack(spacing: XuanSpacing.md) {
                            Rectangle()
                                .fill(Color.xuanBorder)
                                .frame(height: 1)
                            Text("其他登录方式")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextTertiary)
                            Rectangle()
                                .fill(Color.xuanBorder)
                                .frame(height: 1)
                        }

                        HStack(spacing: XuanSpacing.xl3) {
                            // 微信登录
                            Button(action: {
                                showSocialLoginToast = true
                            }) {
                                VStack(spacing: XuanSpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.xuanSurface)
                                            .frame(width: 52, height: 52)
                                        Image("other_mail")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color.xuanSuccess)
                                    }
                                    Text("微信")
                                        .font(XuanFont.caption)
                                        .foregroundColor(Color.xuanTextSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .contentShape(Circle())
                            .accessibilityIdentifier("login_wechat")

                            // Apple 登录
                            Button(action: {
                                showSocialLoginToast = true
                            }) {
                                VStack(spacing: XuanSpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.xuanSurface)
                                            .frame(width: 52, height: 52)
                                        Image("common_settings")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color.xuanTextPrimary)
                                    }
                                    Text("Apple")
                                        .font(XuanFont.caption)
                                        .foregroundColor(Color.xuanTextSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .contentShape(Circle())
                            .accessibilityIdentifier("login_apple")
                        }
                    }
                    .padding(.top, XuanSpacing.lg)

                    // 协议
                    HStack(spacing: 4) {
                        Text("登录即代表同意")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                        Button("《用户协议》") {
                            coordinator.navigate(to: .userAgreement)
                        }
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanApricot)
                        .accessibilityIdentifier("login_user_agreement")
                        Text("和")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                        Button("《隐私政策》") {
                            coordinator.navigate(to: .privacyPolicy)
                        }
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanApricot)
                        .accessibilityIdentifier("login_privacy_policy")
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanDanger)
                            .padding(.top, XuanSpacing.sm)
                    }

                    Spacer()
                }
                .padding(.horizontal, XuanSpacing.xl3)
            }
        }
        .background(Color.xuanApricotBg)
        .overlay(alignment: .top) {
            if showSocialLoginToast {
                Text("第三方登录即将上线，请使用手机号登录")
                    .font(XuanFont.bodyS)
                    .foregroundColor(.white)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.xuanTextPrimary.opacity(0.85))
                    .cornerRadius(XuanRadius.md)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        withAnimation { showSocialLoginToast = false }
                    }
            }
        }
        .onChange(of: viewModel.isLoggedIn) { _, newValue in
            if newValue { coordinator.isLoggedIn = true }
        }
    }

    private func sendVerificationCode() {
        guard phoneNumber.count >= 11 else { return }
        isSendingCode = true
        countdown = 60

        Task {
            // 模拟发送验证码
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }

        // 倒计时
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
