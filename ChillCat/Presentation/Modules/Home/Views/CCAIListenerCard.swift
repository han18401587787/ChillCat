//
//  CCAIListenerCard.swift
//  绪安 - AI 情绪倾听官卡片
//

import SwiftUI

struct CCAIListenerCard: View {
    @State private var viewModel = CCAIListenerViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
        @FocusState private var isInputFocused: Bool

    /// EmojiPicker 显示状态
    @State private var showEmojiPicker = false

    /// 驱动 loading 脉动动画
    @State private var isAnimatingDots = false

    /// matchedGeometryEffect 命名空间
    @Namespace private var modeAnimation

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
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
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(
                    viewModel.crisisDetected && viewModel.riskLevel >= .medium
                        ? AppTheme.error.opacity(0.3)
                        : AppTheme.primary.opacity(0.15),
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $viewModel.showHotlineSheet) {
            crisisHotlineSheet
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "headphones")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.primary)

            Text("今天想和我说什么？")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            // 安全空间徽章
            if viewModel.crisisDetected && viewModel.riskLevel >= .medium {
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                    Text("安全空间")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppTheme.error)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppTheme.error.opacity(0.12))
                .cornerRadius(AppRadius.sm)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    // MARK: - Mode Switcher Bar

    private var modeSwitcherBar: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(CCAIChatMode.allCases, id: \.self) { mode in
                modeButton(mode)
            }
        }
        .padding(.vertical, AppSpacing.xs)
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
                viewModel.currentMode == mode ? .white : AppTheme.textSecondary
            )
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background {
                if viewModel.currentMode == mode {
                    Capsule()
                        .fill(AppTheme.primaryDark)
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
        VStack(spacing: AppSpacing.sm) {
            // 文本输入区域
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty && !isInputFocused {
                    Text(viewModel.currentPlaceholder)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPlaceholder)
                }

                TextField("", text: $viewModel.inputText, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .lineLimit(3...6)
            }
            .frame(minHeight: 80, alignment: .topLeading)
            .background(AppTheme.background)
            .cornerRadius(AppRadius.md)

            // 底部操作栏
            HStack(spacing: AppSpacing.sm) {
                // CCEmojiPicker 触发按钮
                Button {
                    showEmojiPicker = true
                } label: {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

                // 安全计划入口（危机模式可见）
                if viewModel.crisisDetected && viewModel.riskLevel >= .medium {
                    NavigationLink(value: CCAppRoute.safetyPlan) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.crisisRed)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.crisisRed.opacity(0.12))
                            .cornerRadius(AppRadius.sm)
                    }
                }

                // 语音日记入口 (min 44×44 触控区域)
                NavigationLink(value: CCAppRoute.voiceCheckin) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.primaryMuted.opacity(0.25))
                        .cornerRadius(AppRadius.sm)
                }

                // 发送按钮 (min 44×44 触控区域)
                Button {
                    CCHaptic.success()
                    isInputFocused = false
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(viewModel.isSendEnabled ? .white : AppTheme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            viewModel.isSendEnabled
                                ? AppTheme.primary
                                : AppTheme.surface
                        )
                        .cornerRadius(AppRadius.sm)
                }
                .disabled(!viewModel.isSendEnabled)
            }
        }
        // Emoji Picker Sheet
        .sheet(isPresented: $showEmojiPicker) {
            CCEmojiPicker(isShowing: $showEmojiPicker) { emoji in
                viewModel.inputText += emoji.displayName
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Loading

    private var loadingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(AppTheme.primaryMuted)
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
        .padding(.vertical, AppSpacing.sm)
        .onAppear { isAnimatingDots = true }
        .onDisappear { isAnimatingDots = false }
    }

    // MARK: - Responses

    private var responsesSection: some View {
        VStack(spacing: AppSpacing.sm) {
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
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Text(message.emoji)
                    .font(.system(size: 18))

                Text("「\(message.text)」")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)

                Spacer(minLength: 0)
            }

            // 反馈按钮（仅当无反馈时显示）
            if message.feedback == nil {
                HStack(spacing: AppSpacing.lg) {
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
                .foregroundColor(AppTheme.success)
                .padding(.top, 4)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.accentMint.opacity(0.12))
        .cornerRadius(AppRadius.md)
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
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.surface.opacity(0.6))
            .cornerRadius(AppRadius.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Crisis Hotline Button

    private var crisisHotlineButton: some View {
        Button {
            viewModel.showHotlineSheet = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.crisisRed)

                Text("拨打心理援助热线")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.crisisRed)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.crisisRed.opacity(0.6))
            }
            .padding(AppSpacing.md)
            .background(AppTheme.crisisRed.opacity(0.09))
            .cornerRadius(AppRadius.md)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Crisis Hotline Sheet

    private var crisisHotlineSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("心理援助热线")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

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
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(AppSpacing.xl)
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
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "phone.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.crisisRed)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text(number)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.crisisRed)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Button {
                if let url = URL(string: "tel://\(number.filter { $0.isNumber })") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.crisisRed)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.crisisRed.opacity(0.12))
                    .cornerRadius(AppRadius.sm)
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.crisisRed.opacity(0.045))
        .cornerRadius(AppRadius.md)
    }
}
