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
        @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCGratitudeJournalViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
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
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppTheme.background.ignoresSafeArea())

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
                    .foregroundColor(AppTheme.primary)
            }
        }
        .cc_emojiPickerOverlay(isShowing: $viewModel.showEmojiPicker) { emoji in
            viewModel.selectEmoji(emoji.displayName)
        }
        .task {
            viewModel.loadSampleData()
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "8B6F47"))
            VStack(alignment: .leading, spacing: 2) {
                Text("连续 \(viewModel.streakCount) 天")
                    .font(AppFont.title1)
                    .foregroundColor(Color(hex: "8B6F47"))
                Text("坚持感恩记录")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Text("🔥")
                .font(.system(size: 36))
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color(hex: "8B6F47").opacity(0.6).opacity(0.3))
        )
    }

    // MARK: - Date Section

    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(AppTheme.primary)
            DatePicker(
                "选择日期",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .tint(AppTheme.primary)

            Text(viewModel.formattedDate)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Three Things

    private var threeThingsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("今天的三件好事")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            goodThingCard(
                index: 1,
                title: $viewModel.thing1Title,
                reason: $viewModel.thing1Reason,
                emoji: $viewModel.thing1Emoji,
                label: "今天发生的第一件好事",
                color: Color(hex: "66BB6A")
            )

            goodThingCard(
                index: 2,
                title: $viewModel.thing2Title,
                reason: $viewModel.thing2Reason,
                emoji: $viewModel.thing2Emoji,
                label: "第二件好事",
                color: Color(hex: "8B6F47")
            )

            goodThingCard(
                index: 3,
                title: $viewModel.thing3Title,
                reason: $viewModel.thing3Reason,
                emoji: $viewModel.thing3Emoji,
                label: "第三件好事",
                color: Color(hex: "D4C8E8")
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
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                // Emoji button
                Button {
                    viewModel.openEmojiPicker(for: index)
                } label: {
                    Text(emoji.wrappedValue)
                        .font(.system(size: 32))
                        .frame(width: 48, height: 48)
                        .background(color.opacity(0.15))
                        .cornerRadius(AppRadius.sm)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppFont.body.weight(.medium).weight(.medium))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("什么事让你感到感恩？")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            TextField("记录这件好事...", text: title)
                .font(AppFont.body)
                .padding(AppSpacing.sm)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.sm)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("原因是什么？")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
                TextField("为什么会发生这件好事？它对你意味着什么？", text: reason, axis: .vertical)
                    .font(AppFont.footnote)
                    .padding(AppSpacing.sm)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.sm)
                    .lineLimit(2...4)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
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
            .font(AppFont.body.weight(.medium).weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                viewModel.canSubmit
                    ? LinearGradient(
                        colors: [Color(hex: "66BB6A"), Color(hex: "8B6F47")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [AppTheme.textSecondary, AppTheme.textSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppRadius.md)
        }
        .disabled(!viewModel.canSubmit)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            if !viewModel.pastEntries.isEmpty {
                Text("感恩记录")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)

                ForEach(viewModel.pastEntries) { entry in
                    historyEntryCard(entry)
                }
            }
        }
    }

    private func historyEntryCard(_ entry: CCGratitudeEntry) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
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
                    .foregroundColor(AppTheme.textSecondary)
                Text(dateStr)
                    .font(AppFont.footnote.weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            }

            // Three things
            ForEach(entry.things) { thing in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Text(thing.emoji)
                        .font(.system(size: 18))
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(thing.title)
                            .font(AppFont.footnote.weight(.medium))
                            .foregroundColor(AppTheme.textPrimary)
                        if !thing.reason.isEmpty {
                            Text(thing.reason)
                                .font(AppFont.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
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

            VStack(spacing: AppSpacing.xl) {
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
                    .font(AppFont.largeTitle)
                    .foregroundColor(AppTheme.textPrimary)

                Text(viewModel.completionMessage)
                    .font(AppFont.body.weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            )
            .padding(AppSpacing.xl)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCGratitudeJournalView().environment(CCAppCoordinator())
    }
}
