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
                VStack(spacing: XuanSpacing.xl) {
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
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.top, XuanSpacing.sm)
                .padding(.bottom, XuanSpacing.xl)
            }
            .background(Color.xuanApricotBg.ignoresSafeArea())

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
                    .foregroundColor(Color.xuanApricot)
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
        HStack(spacing: XuanSpacing.sm) {
            Image("emotion_angry")
                .font(.system(size: 24))
                .foregroundColor(Color.xuanApricotDark)
            VStack(alignment: .leading, spacing: 2) {
                Text("连续 \(viewModel.streakCount) 天")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanApricotDark)
                Text("坚持感恩记录")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()
            Text("🔥")
                .font(.system(size: 36))
        }
        .padding(XuanSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: XuanRadius.md)
                .fill(Color.xuanApricotDark.opacity(0.6).opacity(0.3))
        )
    }

    // MARK: - Date Section

    private var dateSection: some View {
        HStack {
            Image("other_calendar")
                .foregroundColor(Color.xuanApricot)
            DatePicker(
                "选择日期",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .tint(Color.xuanApricot)

            Text(viewModel.formattedDate)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Three Things

    private var threeThingsSection: some View {
        VStack(spacing: XuanSpacing.lg) {
            Text("今天的三件好事")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            goodThingCard(
                index: 1,
                title: $viewModel.thing1Title,
                reason: $viewModel.thing1Reason,
                emoji: $viewModel.thing1Emoji,
                label: "今天发生的第一件好事",
                color: Color.xuanMint
            )

            goodThingCard(
                index: 2,
                title: $viewModel.thing2Title,
                reason: $viewModel.thing2Reason,
                emoji: $viewModel.thing2Emoji,
                label: "第二件好事",
                color: Color.xuanApricotDark
            )

            goodThingCard(
                index: 3,
                title: $viewModel.thing3Title,
                reason: $viewModel.thing3Reason,
                emoji: $viewModel.thing3Emoji,
                label: "第三件好事",
                color: Color(hex: "A085C6")
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
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                // Emoji button
                Button {
                    viewModel.openEmojiPicker(for: index)
                } label: {
                    Text(emoji.wrappedValue)
                        .font(.system(size: 32))
                        .frame(width: 48, height: 48)
                        .background(color.opacity(0.15))
                        .cornerRadius(XuanRadius.sm)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text("什么事让你感到感恩？")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()
            }

            TextField("记录这件好事...", text: title)
                .font(XuanFont.bodyL)
                .padding(XuanSpacing.sm)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.sm)

            VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                Text("原因是什么？")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                TextField("为什么会发生这件好事？它对你意味着什么？", text: reason, axis: .vertical)
                    .font(XuanFont.bodyS)
                    .padding(XuanSpacing.sm)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.sm)
                    .lineLimit(2...4)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.md)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            viewModel.submitEntry()
        } label: {
            HStack {
                Image("resonance_like")
                Text("记录今天的好事")
            }
            .font(XuanFont.bodyLMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.md)
            .background(
                viewModel.canSubmit
                    ? LinearGradient(
                        colors: [Color.xuanMint, Color.xuanApricotDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.xuanTextSecondary, Color.xuanTextSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(XuanRadius.md)
        }
        .disabled(!viewModel.canSubmit)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            if !viewModel.pastEntries.isEmpty {
                Text("感恩记录")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)

                ForEach(viewModel.pastEntries) { entry in
                    historyEntryCard(entry)
                }
            }
        }
    }

    private func historyEntryCard(_ entry: CCGratitudeEntry) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            // Date header
            HStack {
                let formatter = DateFormatter()
                let dateStr: String = {
                    formatter.dateFormat = "M月d日"
                    formatter.locale = Locale(identifier: "zh_CN")
                    return formatter.string(from: entry.date)
                }()

                Image("other_calendar")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanTextSecondary)
                Text(dateStr)
                    .font(XuanFont.bodyS.weight(.medium))
                    .foregroundColor(Color.xuanTextSecondary)
                Spacer()
            }

            // Three things
            ForEach(entry.things) { thing in
                HStack(alignment: .top, spacing: XuanSpacing.sm) {
                    Text(thing.emoji)
                        .font(.system(size: 18))
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(thing.title)
                            .font(XuanFont.bodyS.weight(.medium))
                            .foregroundColor(Color.xuanTextPrimary)
                        if !thing.reason.isEmpty {
                            Text(thing.reason)
                                .font(XuanFont.bodyM)
                                .foregroundColor(Color.xuanTextSecondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
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

            VStack(spacing: XuanSpacing.xl) {
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
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)

                Text(viewModel.completionMessage)
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, XuanSpacing.lg)
            }
            .padding(XuanSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.xl)
                    .fill(Color.xuanWhite)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            )
            .padding(XuanSpacing.xl)
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
