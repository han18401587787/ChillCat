import SwiftUI

/// 情绪解码器 — §2.5
struct CCEmotionDecoderView: View {
    @State private var viewModel = CCEmotionDecoderViewModel()
    @State private var showEmoji = false
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                // Header
                headerSection

                // Input area
                if !viewModel.showResult {
                    inputSection
                }

                // Loading
                if viewModel.isLoading {
                    VStack(spacing: theme.spacingMD) {
                        ProgressView()
                            .scaleEffect(1.3)
                        Text("正在解码你的情绪…")
                            .font(.system(size: 15))
                            .foregroundColor(theme.textSecondary)
                    }
                    .padding(.vertical, 60)
                }

                // Result layers
                if viewModel.showResult {
                    resultDisplay

                    // Reset button
                    Button(action: { viewModel.reset() }) {
                        Text("再试一次")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(theme.primary.opacity(0.1))
                            .cornerRadius(theme.radiusMD)
                    }
                    .padding(.top, theme.spacingSM)
                }

                // Error
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(theme.error)
                        Text(error)
                            .foregroundColor(theme.error)
                    }
                    .font(.system(size: 14))
                    .padding()
                    .background(theme.error.opacity(0.08))
                    .cornerRadius(theme.radiusSM)
                }
            }
            .padding()
        }
        .background(theme.background)
        .overlay(alignment: .bottom) {
            if showEmoji {
                CCEmojiPicker(isShowing: $showEmoji) { emoji in
                    viewModel.inputText += emoji
                }
                .frame(height: 280)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showEmoji)
        .navigationTitle("情绪解码")
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("🧠 情绪解码")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.textPrimary)
            Spacer()
        }
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(spacing: theme.spacingMD) {
            Text("写下让你困惑的感受，AI 帮你一层层拆解")
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.inputText)
                    .focused($isFocused)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(12)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                HStack(spacing: 8) {
                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(theme.primary)
                            .frame(width: 36, height: 36)
                            .background(theme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 8)
                    .padding(.trailing, 4)
                }
            }

            Button(action: {
                CCHaptic.medium()
                isFocused = false
                Task { await viewModel.decode() }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle.magnifyingglass")
                    Text("开始解码")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.canDecode ? theme.primary : theme.textMuted)
                .cornerRadius(theme.radiusMD)
            }
            .disabled(!viewModel.canDecode)
        }
    }

    // MARK: - Result Display

    private var resultDisplay: some View {
        VStack(spacing: 0) {
            // Layer 1: Surface Emotion
            if viewModel.showSurface {
                layerCard(
                    title: "表层情绪",
                    icon: viewModel.surfaceEmotion?.icon ?? "😰",
                    label: viewModel.surfaceEmotion?.label ?? "",
                    confidence: viewModel.surfaceEmotion?.confidence,
                    color: theme.softPurple,
                    bgColor: theme.softPurpleLight.opacity(0.2)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if viewModel.showResult {
                // Placeholder
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
            }

            // Arrow
            animatedArrow
                .opacity(viewModel.showSurface ? 1 : 0)

            // Layer 2: Middle Emotions
            if viewModel.showMiddle {
                VStack(spacing: 8) {
                    Text("中层情绪")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    ForEach(viewModel.middleEmotions) { emotion in
                        HStack(spacing: 10) {
                            Text(emotion.icon)
                                .font(.system(size: 20))
                            Text(emotion.label)
                                .font(.system(size: 15))
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                            if let confidence = emotion.confidence {
                                Text("\(Int(confidence * 100))%")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textMuted)
                            }
                        }
                        .padding()
                        .background(theme.softPink.opacity(0.15))
                        .cornerRadius(theme.radiusMD)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if viewModel.showSurface {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
            }

            // Arrow
            if viewModel.showMiddle {
                animatedArrow
            }

            // Layer 3: Deep Needs
            if viewModel.showDeep {
                VStack(spacing: 8) {
                    Text("深层需求")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    ForEach(viewModel.deepNeeds) { need in
                        HStack(spacing: 10) {
                            Text("💚")
                                .font(.system(size: 18))
                            Text(need.label)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(theme.textPrimary)
                            Spacer()
                        }
                        .padding()
                        .background(theme.softGreenLight.opacity(0.3))
                        .cornerRadius(theme.radiusMD)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if viewModel.showMiddle {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
            }

            // Suggestions
            if viewModel.showSuggestions {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("💡 建议行动")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.textPrimary)

                    ForEach(viewModel.suggestions) { suggestion in
                        HStack(spacing: 12) {
                            Image(systemName: suggestion.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(suggestionColor(suggestion.colorName))
                                .frame(width: 36, height: 36)
                                .background(suggestionColor(suggestion.colorName).opacity(0.15))
                                .cornerRadius(theme.radiusSM)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(theme.textPrimary)
                                Text(suggestion.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.textSecondary)
                                    .lineSpacing(3)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(theme.radiusMD)
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    // MARK: - Layer Card

    private func layerCard(title: String, icon: String, label: String, confidence: Double?, color: Color, bgColor: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            HStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
                if let confidence = confidence {
                    Text("\(Int(confidence * 100))%")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                }
            }
            .padding()
            .background(bgColor)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Animated Arrow

    private var animatedArrow: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.primaryMuted.opacity(0.4))
                .frame(width: 2, height: 24)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(theme.primaryMuted.opacity(0.6))
                .scaleEffect(arrowScale)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: arrowScale
                )
        }
        .onAppear { arrowScale = 1.2 }
    }

    @State private var arrowScale: CGFloat = 1.0

    // MARK: - Helpers

    private func suggestionColor(_ name: String) -> Color {
        switch name {
        case "softPurple": return theme.softPurple
        case "softPink": return theme.softPink
        case "warmLight": return theme.warmLight
        case "softGreen": return theme.softGreen
        case "primaryMuted": return theme.primaryMuted
        default: return theme.primaryMuted
        }
    }
}
