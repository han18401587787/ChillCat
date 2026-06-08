//
//  CCHomeView.swift
//  绪安 - 首页情绪打卡
//

import SwiftUI

struct CCHomeView: View {
    @State private var viewModel = CCEmotionViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                // 头部问候
                headerSection

                // 情绪选择
                if !viewModel.hasCheckedIn {
                    emotionCheckInSection
                } else {
                    checkedInCard
                }

                // 今日任务
                dailyTaskSection

                // 本周回顾
                weeklyReviewCard

                // 每日语录
                quoteCard
            }
            .padding()
        }
        .background(theme.background)
        .navigationTitle("绪安")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("现在是什么感受？")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                Text("已陪伴你 \(viewModel.totalDays) 天")
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            Text("连续\(viewModel.streakDays)天")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(theme.primaryMuted.opacity(0.3))
                .cornerRadius(theme.radiusSM)
        }
    }

    // MARK: - Emotion Grid
    private var emotionCheckInSection: some View {
        VStack(spacing: theme.spacingMD) {
            LazyVGrid(columns: columns, spacing: theme.spacingSM) {
                ForEach(CCEmotion.allCases) { emotion in
                    emotionButton(emotion)
                }
            }

            if let selected = viewModel.selectedEmotion {
                VStack(spacing: theme.spacingMD) {
                    TextField("不用勉强说…", text: $viewModel.todayNote, axis: .vertical)
                        .font(.system(size: 15))
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(theme.radiusMD)
                        .lineLimit(3...5)

                    Button(action: { viewModel.completeCheckIn() }) {
                        Text("就是这样，进去看看")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.primary)
                            .cornerRadius(theme.radiusMD)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedEmotion)
    }

    private func emotionButton(_ emotion: CCEmotion) -> some View {
        Button(action: { viewModel.selectEmotion(emotion) }) {
            VStack(spacing: 6) {
                Image(systemName: emotion.iconName)
                    .font(.system(size: 22))
                Text(emotion.rawValue)
                    .font(.system(size: 11))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.selectedEmotion == emotion
                    ? theme.primary.opacity(0.15)
                    : theme.surface
            )
            .cornerRadius(theme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusMD)
                    .stroke(
                        viewModel.selectedEmotion == emotion
                            ? theme.primary : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .foregroundColor(theme.textPrimary)
    }

    // MARK: - Checked In State
    private var checkedInCard: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(theme.softGreen)
            Text("今日已打卡")
                .font(.system(size: 18, weight: .semibold))
            Text("完成了！你真的很棒")
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingLG)
        .background(theme.softGreenLight.opacity(0.3))
        .cornerRadius(theme.radiusLG)
    }

    // MARK: - Daily Task
    private var dailyTaskSection: some View {
        HStack {
            Button(action: { viewModel.completeDailyTask() }) {
                Image(systemName: viewModel.dailyTaskCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.dailyTaskCompleted ? theme.softGreen : theme.textMuted)
            }

            Text(viewModel.dailyTask)
                .font(.system(size: 15))
                .foregroundColor(
                    viewModel.dailyTaskCompleted ? theme.textSecondary : theme.textPrimary
                )
                .strikethrough(viewModel.dailyTaskCompleted)

            Spacer()
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Weekly Review
    private var weeklyReviewCard: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            HStack {
                Text("本周情绪回顾")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("本周 14 个")
                    .font(.system(size: 13))
                    .foregroundColor(theme.textSecondary)
            }

            Text(viewModel.weeklyNote)
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Quote
    private var quoteCard: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20))
                .foregroundColor(theme.primaryMuted)

            Text(viewModel.quote)
                .font(.system(size: 15))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "quote.closing")
                .font(.system(size: 20))
                .foregroundColor(theme.primaryMuted)
        }
        .padding(theme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(theme.softPurpleLight.opacity(0.3))
        .cornerRadius(theme.radiusLG)
    }
}
