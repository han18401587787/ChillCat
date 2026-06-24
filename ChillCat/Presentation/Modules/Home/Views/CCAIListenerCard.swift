//
//  CCAIListenerCard.swift
//  绪安 - AI 情绪倾听官卡片
//

import SwiftUI

struct CCAIListenerCard: View {
    @State private var viewModel = CCAIListenerViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isInputFocused: Bool

    /// EmojiPicker 显示状态
    @State private var showEmojiPicker = false

    /// 驱动 loading 脉动动画
    @State private var isAnimatingDots = false

    /// matchedGeometryEffect 命名空间
    @Namespace private var modeAnimation

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            // MARK: - Header
            headerSection

            // MARK: - Mode Switcher
            modeSwitcherBar

            // MARK: - Input Area
            inputSection

            // MARK: - Loading State
            if viewModel.isLoading {
                loadingIndicator
            }

            // MARK: - AI Response Bubbles
            if !viewModel.aiResponses.isEmpty {
                responsesSection
            }

            // MARK: - Crisis Hotline Button
            if viewModel.crisisDetected && viewModel.riskLevel >= .medium {
                crisisHotlineButton
            }
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radiusLG)
                .stroke(
                    viewModel.crisisDetected && viewModel.riskLevel >= .medium
                        ? theme.error.opacity(0.3)
                        : theme.primaryMuted.opacity(0.3),
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $viewModel.showHotlineSheet) {
            crisisHotlineSheet
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: theme.spacingSM) {
            Image(systemName: "headphones")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(theme.primary)

            Text("今天想和我说什么？")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.textPrimary)

            Spacer()

            // 安全空间徽章
            if viewModel.crisisDetected && viewModel.riskLevel >= .medium {
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                    Text("安全空间")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(theme.error)
                .padding(.horizontal, theme.spacingSM)
                .padding(.vertical, theme.spacingXS)
                .background(theme.errorLight.opacity(0.6))
                .cornerRadius(theme.radiusSM)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    // MARK: - Mode Switcher Bar

    private var modeSwitcherBar: some View {
        HStack(spacing: theme.spacingSM) {
            ForEach(CCAIChatMode.allCases, id: \.self) { mode in
                modeButton(mode)
            }
        }
        .padding(.vertical, theme.spacingXS)
    }

    private func modeButton(_ mode: CCAIChatMode) -> some View {
        Button {
            CCHaptic.selection()
            viewModel.switchMode(mode)
        } label: {
            HStack(spacing: 4) {
                Text(mode.emoji)
                    .font(.system(size: 14))
                Text(mode.displayName)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(
                viewModel.currentMode == mode ? .white : theme.textSecondary
            )
            .padding(.horizontal, theme.spacingMD)
            .padding(.vertical, theme.spacingSM)
            .background {
                if viewModel.currentMode == mode {
                    Capsule()
                        .fill(theme.xuanBlue)
                        .matchedGeometryEffect(id: "mode_background", in: modeAnimation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(spacing: theme.spacingSM) {
            // 文本输入区域
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty && !isInputFocused {
                    Text(viewModel.currentPlaceholder)
                        .font(.system(size: 15))
                        .foregroundColor(theme.textMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPlaceholder)
                }

                TextField("", text: $viewModel.inputText, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundColor(theme.textPrimary)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .lineLimit(3...6)
            }
            .frame(minHeight: 80, alignment: .topLeading)
            .background(theme.background)
            .cornerRadius(theme.radiusMD)

            // 底部操作栏
            HStack(spacing: theme.spacingSM) {
                // CCEmojiPicker 触发按钮
                Button {
                    showEmojiPicker = true
                } label: {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 18))
                        .foregroundColor(theme.textMuted)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

                // 安全计划入口（危机模式可见）
                if viewModel.crisisDetected && viewModel.riskLevel >= .medium {
                    NavigationLink(value: CCAppRoute.safetyPlan) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.error)
                            .frame(width: 44, height: 44)
                            .background(theme.errorLight.opacity(0.4))
                            .cornerRadius(theme.radiusSM)
                    }
                }

                // 语音日记入口 (min 44×44 触控区域)
                NavigationLink(value: CCAppRoute.voiceCheckin) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                        .frame(width: 44, height: 44)
                        .background(theme.primaryMuted.opacity(0.25))
                        .cornerRadius(theme.radiusSM)
                }

                // 发送按钮 (min 44×44 触控区域)
                Button {
                    CCHaptic.success()
                    isInputFocused = false
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(viewModel.isSendEnabled ? .white : theme.textMuted)
                        .frame(width: 44, height: 44)
                        .background(
                            viewModel.isSendEnabled
                                ? theme.primary
                                : theme.surface
                        )
                        .cornerRadius(theme.radiusSM)
                }
                .disabled(!viewModel.isSendEnabled)
            }
        }
        // Emoji Picker Sheet
        .sheet(isPresented: $showEmojiPicker) {
            CCEmojiPicker(isShowing: $showEmojiPicker) { emoji in
                viewModel.inputText += emoji
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Loading

    private var loadingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(theme.primaryMuted)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimatingDots ? 1.5 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimatingDots
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingSM)
        .onAppear { isAnimatingDots = true }
        .onDisappear { isAnimatingDots = false }
    }

    // MARK: - Responses

    private var responsesSection: some View {
        VStack(spacing: theme.spacingSM) {
            ForEach(viewModel.aiResponses) { message in
                responseBubble(message)
                    .transition(
                        .opacity
                            .combined(with: .move(edge: .bottom))
                    )
            }
        }
    }

    private func responseBubble(_ message: CCAIResponseMessage) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingXS) {
            HStack(alignment: .top, spacing: theme.spacingSM) {
                Text(message.emoji)
                    .font(.system(size: 18))

                Text("「\(message.text)」")
                    .font(.system(size: 15))
                    .foregroundColor(theme.textPrimary)
                    .lineSpacing(4)

                Spacer(minLength: 0)
            }

            // 反馈按钮（仅当无反馈时显示）
            if message.feedback == nil {
                HStack(spacing: theme.spacingLG) {
                    feedbackButton(label: "有用", icon: "hand.thumbsup", for: message, isHelpful: true)
                    feedbackButton(label: "不太对", icon: "hand.thumbsdown", for: message, isHelpful: false)
                }
                .padding(.top, 4)
            } else {
                // 已反馈提示
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("感谢反馈")
                        .font(.system(size: 12))
                }
                .foregroundColor(theme.softGreen)
                .padding(.top, 4)
            }
        }
        .padding(theme.spacingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.softGreenLight.opacity(0.25))
        .cornerRadius(theme.radiusMD)
    }

    private func feedbackButton(
        label: String,
        icon: String,
        for message: CCAIResponseMessage,
        isHelpful: Bool
    ) -> some View {
        Button {
            CCHaptic.selection()
            viewModel.submitFeedback(for: message, isHelpful: isHelpful)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 13))
            }
            .foregroundColor(theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(theme.surface.opacity(0.6))
            .cornerRadius(theme.radiusSM)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Crisis Hotline Button

    private var crisisHotlineButton: some View {
        Button {
            viewModel.showHotlineSheet = true
        } label: {
            HStack(spacing: theme.spacingSM) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.error)

                Text("拨打心理援助热线")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.error)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.error.opacity(0.6))
            }
            .padding(theme.spacingMD)
            .background(theme.errorLight.opacity(0.3))
            .cornerRadius(theme.radiusMD)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Crisis Hotline Sheet

    private var crisisHotlineSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                Text("心理援助热线")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(theme.textPrimary)

                hotlineRow(
                    title: "24小时心理援助热线",
                    number: "400-161-9995",
                    subtitle: "全国通用 · 全天候"
                )

                hotlineRow(
                    title: "北京心理危机研究与干预中心",
                    number: "010-82951332",
                    subtitle: "北京地区 · 24小时"
                )

                hotlineRow(
                    title: "生命热线",
                    number: "400-821-1215",
                    subtitle: "全国通用 · 24小时"
                )

                hotlineRow(
                    title: "希望24热线",
                    number: "400-161-9995",
                    subtitle: "全国通用 · 全天候"
                )

                Spacer()

                Text("你不是一个人。拨打电话，专业人员会帮助你。")
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(theme.spacingXL)
            .navigationTitle("热线电话")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        viewModel.showHotlineSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func hotlineRow(title: String, number: String, subtitle: String) -> some View {
        HStack(spacing: theme.spacingMD) {
            Image(systemName: "phone.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(theme.error)

            VStack(alignment: .leading, spacing: theme.spacingXS) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.textPrimary)

                Text(number)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.error)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
            }

            Spacer()

            Button {
                if let url = URL(string: "tel://\(number.filter { $0.isNumber })") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.error)
                    .frame(width: 44, height: 44)
                    .background(theme.errorLight.opacity(0.4))
                    .cornerRadius(theme.radiusSM)
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacingMD)
        .background(theme.errorLight.opacity(0.15))
        .cornerRadius(theme.radiusMD)
    }
}
