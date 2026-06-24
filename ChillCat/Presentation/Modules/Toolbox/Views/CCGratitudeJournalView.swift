//
//  CCGratitudeJournalView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 感恩日记 View
//

import SwiftUI

// MARK: - Gratitude Journal View

struct CCGratitudeJournalView: View {
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCGratitudeJournalViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: theme.spacingXL) {
                    // Streak counter
                    streakBanner

                    // Date picker
                    dateSection

                    // Three good things cards
                    threeThingsSection

                    // Submit button
                    submitButton

                    // History
                    historySection
                }
                .padding(.horizontal, theme.spacingLG)
                .padding(.top, theme.spacingSM)
                .padding(.bottom, theme.spacing3XL)
            }
            .background(theme.background.ignoresSafeArea())

            // Completion animation overlay
            if viewModel.showCompletionAnimation {
                completionOverlay
            }
        }
        .navigationTitle("感恩日记")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(theme.primary)
            }
        }
        .cc_emojiPickerOverlay(isShowing: $viewModel.showEmojiPicker) { emoji in
            viewModel.selectEmoji(emoji)
        }
        .task {
            viewModel.loadSampleData()
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: theme.spacingSM) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(theme.warm)
            VStack(alignment: .leading, spacing: 2) {
                Text("连续 \(viewModel.streakCount) 天")
                    .font(theme.fontH2)
                    .foregroundColor(theme.warm)
                Text("坚持感恩记录")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            Text("🔥")
                .font(.system(size: 36))
        }
        .padding(theme.spacingLG)
        .background(
            RoundedRectangle(cornerRadius: theme.radiusMD)
                .fill(theme.warmMuted.opacity(0.3))
        )
    }

    // MARK: - Date Section

    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(theme.primary)
            DatePicker(
                "选择日期",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .tint(theme.primary)

            Text(viewModel.formattedDate)
                .font(theme.fontBody)
                .foregroundColor(theme.textPrimary)

            Spacer()
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Three Things

    private var threeThingsSection: some View {
        VStack(spacing: theme.spacingLG) {
            Text("今天的三件好事")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            goodThingCard(
                index: 1,
                title: $viewModel.thing1Title,
                reason: $viewModel.thing1Reason,
                emoji: $viewModel.thing1Emoji,
                label: "今天发生的第一件好事",
                color: theme.softGreen
            )

            goodThingCard(
                index: 2,
                title: $viewModel.thing2Title,
                reason: $viewModel.thing2Reason,
                emoji: $viewModel.thing2Emoji,
                label: "第二件好事",
                color: theme.warm
            )

            goodThingCard(
                index: 3,
                title: $viewModel.thing3Title,
                reason: $viewModel.thing3Reason,
                emoji: $viewModel.thing3Emoji,
                label: "第三件好事",
                color: theme.softPurple
            )
        }
    }

    private func goodThingCard(
        index: Int,
        title: Binding<String>,
        reason: Binding<String>,
        emoji: Binding<String>,
        label: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            HStack {
                // Emoji button
                Button {
                    viewModel.openEmojiPicker(for: index)
                } label: {
                    Text(emoji.wrappedValue)
                        .font(.system(size: 32))
                        .frame(width: 48, height: 48)
                        .background(color.opacity(0.15))
                        .cornerRadius(theme.radiusSM)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(theme.textPrimary)
                    Text("什么事让你感到感恩？")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                }

                Spacer()
            }

            TextField("记录这件好事...", text: title)
                .font(theme.fontBody)
                .padding(theme.spacingSM)
                .background(theme.surface)
                .cornerRadius(theme.radiusSM)

            VStack(alignment: .leading, spacing: theme.spacingXS) {
                Text("原因是什么？")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
                TextField("为什么会发生这件好事？它对你意味着什么？", text: reason, axis: .vertical)
                    .font(theme.fontBodyS)
                    .padding(theme.spacingSM)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusSM)
                    .lineLimit(2...4)
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radiusMD)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            viewModel.submitEntry()
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                Text("记录今天的好事")
            }
            .font(theme.fontBodyL.weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacingMD)
            .background(
                viewModel.canSubmit
                    ? LinearGradient(
                        colors: [theme.softGreen, theme.warm],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [theme.textMuted, theme.textMuted],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(theme.radiusMD)
        }
        .disabled(!viewModel.canSubmit)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            if !viewModel.pastEntries.isEmpty {
                Text("感恩记录")
                    .font(theme.fontH2)
                    .foregroundColor(theme.textPrimary)

                ForEach(viewModel.pastEntries) { entry in
                    historyEntryCard(entry)
                }
            }
        }
    }

    private func historyEntryCard(_ entry: CCGratitudeEntry) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            // Date header
            HStack {
                let formatter = DateFormatter()
                let dateStr: String = {
                    formatter.dateFormat = "M月d日"
                    formatter.locale = Locale(identifier: "zh_CN")
                    return formatter.string(from: entry.date)
                }()

                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                Text(dateStr)
                    .font(theme.fontBodyS.weight(.medium))
                    .foregroundColor(theme.textSecondary)
                Spacer()
            }

            // Three things
            ForEach(entry.things) { thing in
                HStack(alignment: .top, spacing: theme.spacingSM) {
                    Text(thing.emoji)
                        .font(.system(size: 18))
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(thing.title)
                            .font(theme.fontBodyS.weight(.medium))
                            .foregroundColor(theme.textPrimary)
                        if !thing.reason.isEmpty {
                            Text(thing.reason)
                                .font(theme.fontCaption)
                                .foregroundColor(theme.textMuted)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        viewModel.showCompletionAnimation = false
                    }
                }

            VStack(spacing: theme.spacingXL) {
                // Confetti-like emoji burst
                ZStack {
                    ForEach(0..<12, id: \.self) { i in
                        let emojis = ["🌟", "✨", "💚", "🌸", "💫", "🎉", "💖", "🌻", "🦋", "⭐", "💝", "🌈"]
                        Text(emojis[i])
                            .font(.system(size: 24))
                            .offset(
                                x: CGFloat.random(in: -80...80),
                                y: CGFloat.random(in: -80...80)
                            )
                            .opacity(viewModel.showCompletionAnimation ? 1 : 0)
                            .scaleEffect(viewModel.showCompletionAnimation ? 1 : 0.3)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                .delay(Double(i) * 0.05),
                                value: viewModel.showCompletionAnimation
                            )
                    }
                }
                .frame(height: 160)

                Text("记录完成！")
                    .font(theme.fontH1)
                    .foregroundColor(theme.textPrimary)

                Text(viewModel.completionMessage)
                    .font(theme.fontBodyL)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacingLG)
            }
            .padding(theme.spacing2XL)
            .background(
                RoundedRectangle(cornerRadius: theme.radiusXL)
                    .fill(theme.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            )
            .padding(theme.spacing2XL)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCGratitudeJournalView()
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}
