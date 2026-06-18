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

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // MARK: - Header
            headerSection

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

        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppTheme.primaryMuted.opacity(0.3), lineWidth: 1)
        )
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
        }
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(spacing: AppSpacing.sm) {
            // 文本输入区域
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty && !isInputFocused {
                    Text(viewModel.currentPlaceholder)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
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
                        .foregroundColor(AppTheme.textMuted)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

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
                        .foregroundColor(viewModel.isSendEnabled ? .white : AppTheme.textMuted)
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
        // Emoji Picker Overlay (v3)
        .cc_emojiPickerV3Overlay(isShowing: $showEmojiPicker) { emoji in
            viewModel.inputText += emoji.displayName
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
                .foregroundColor(AppTheme.softGreen)
                .padding(.top, 4)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.softGreenLight.opacity(0.25))
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
}
