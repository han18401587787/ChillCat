//
//  CCValuesExplorerView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 价值观探索 View
//

import SwiftUI

// MARK: - Values Explorer View

struct CCValuesExplorerView: View {
        @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCValuesExplorerViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Step progress
                stepProgressBar

                // Content
                Group {
                    switch viewModel.currentStep {
                    case .selectTen:
                        stepSelectValues
                    case .rankTopFive:
                        stepRankValues
                    case .reflectOnValues:
                        stepReflectValues
                    case .rateAlignment:
                        stepRateAlignment
                    case .actionPlan:
                        stepActionPlan
                    case .completed:
                        completionView
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                // Navigation
                if viewModel.currentStep != .completed {
                    navigationButtons
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("价值观探索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(AppTheme.primary)
            }
        }
    }

    // MARK: - Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Circle()
                        .fill(step.rawValue < viewModel.currentStep.rawValue
                              ? Color(hex: "8B6F47") : (step.rawValue == viewModel.currentStep.rawValue
                                              ? Color(hex: "8B6F47") : AppTheme.border))
                        .frame(width: 10, height: 10)
                    if step.rawValue < CCValuesStep.completed.rawValue {
                        Rectangle()
                            .fill(step.rawValue < viewModel.currentStep.rawValue ? Color(hex: "8B6F47") : AppTheme.border)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(AppFont.caption)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? Color(hex: "8B6F47") : AppTheme.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Step 1: Select Values

    private var stepSelectValues: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeaderView

            Text("已选择 \(viewModel.selectedValues.count)/10")
                .font(AppFont.body)
                .foregroundColor(
                    viewModel.selectedValues.count >= 5 ? Color(hex: "66BB6A") : AppTheme.textSecondary
                )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(CCValueCard.all) { value in
                    valueCard(value: value, isSelected: viewModel.selectedValues.contains(value.id))
                }
            }
        }
    }

    private func valueCard(value: CCValueCard, isSelected: Bool) -> some View {
        Button {
            CCHaptic.light()
            viewModel.toggleValue(value.id)
        } label: {
            VStack(spacing: AppSpacing.xs) {
                Text(value.emoji)
                    .font(.system(size: 28))
                Text(value.name)
                    .font(AppFont.footnote.weight(.medium))
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                Text(value.description)
                    .font(AppFont.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(isSelected ? Color(hex: "8B6F47") : AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .stroke(isSelected ? Color(hex: "8B6F47") : AppTheme.border, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Rank Values

    private var stepRankValues: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeaderView

            Text("拖拽排列最重要的5个价值观（从上到下为最重要到最不重要）")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)

            // Show all selected values, let user pick 5 to rank
            VStack(spacing: AppSpacing.sm) {
                ForEach(Array(viewModel.selectedValues), id: \.self) { valueId in
                    if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                        let isInTopFive = viewModel.rankedValues.contains(valueId)
                        let rank = viewModel.rankedValues.firstIndex(of: valueId).map { $0 + 1 }

                        Button {
                            CCHaptic.selection()
                            if isInTopFive {
                                viewModel.rankedValues.removeAll { $0 == valueId }
                            } else if viewModel.rankedValues.count < 5 {
                                viewModel.rankedValues.append(valueId)
                            }
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                // Rank number or selection indicator
                                if let rank = rank {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "8B6F47"))
                                            .frame(width: 28, height: 28)
                                        Text("\(rank)")
                                            .font(AppFont.footnote.weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Circle()
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                        .frame(width: 28, height: 28)
                                }

                                Text(value.emoji)
                                    .font(.system(size: 22))
                                Text(value.name)
                                    .font(AppFont.body)
                                    .foregroundColor(isInTopFive ? AppTheme.textPrimary : AppTheme.textSecondary)
                                Spacer()
                                Image(systemName: isInTopFive ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isInTopFive ? Color(hex: "8B6F47") : AppTheme.textSecondary)
                                    .font(.system(size: 20))
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.sm)
                                    .fill(isInTopFive ? Color(hex: "8B6F47").opacity(0.6).opacity(0.5) : AppTheme.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Display current ranking
            if !viewModel.rankedValues.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("当前排序")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("使用右侧手柄拖拽调整顺序")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                        if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                            HStack(spacing: AppSpacing.md) {
                                Text("\(index + 1)")
                                    .font(AppFont.title1)
                                    .foregroundColor(Color(hex: "8B6F47"))
                                    .frame(width: 28)
                                Text(value.emoji)
                                    .font(.system(size: 24))
                                Text(value.name)
                                    .font(AppFont.body.weight(.medium))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(AppSpacing.md)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppRadius.sm)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Reflect

    private var stepReflectValues: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeaderView

            ForEach(viewModel.rankedValues, id: \.self) { valueId in
                if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text(value.emoji)
                                .font(.system(size: 20))
                            Text(value.name)
                                .font(AppFont.title3)
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text("我在做什么时体现了这个价值？")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textSecondary)

                        TextField(
                            "例如：当我和家人一起吃饭聊天时...",
                            text: Binding(
                                get: { viewModel.valueReflections[valueId] ?? "" },
                                set: { viewModel.setReflection(for: valueId, text: $0) }
                            ),
                            axis: .vertical
                        )
                        .font(AppFont.body)
                        .padding(AppSpacing.md)
                        .background(AppTheme.surface)
                        .cornerRadius(AppRadius.sm)
                        .lineLimit(2...4)
                    }
                    .padding(AppSpacing.lg)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppRadius.md)
                }
            }
        }
    }

    // MARK: - Step 4: Rate Alignment

    private var stepRateAlignment: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeaderView

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("当前行为与价值观的一致性")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                Text("1 = 完全不一致，10 = 完全一致")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)

                HStack {
                    Text("不一致")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.alignmentRating))/10")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color(hex: "8B6F47"))
                    Spacer()
                    Text("完全一致")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Slider(value: $viewModel.alignmentRating, in: 1...10, step: 1)
                    .tint(Color(hex: "8B6F47"))

                if !viewModel.alignmentDescription.isEmpty {
                    Text(viewModel.alignmentDescription)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, AppSpacing.sm)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Step 5: Action Plan

    private var stepActionPlan: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeaderView

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("制定一个小行动")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                Text("想一个具体的、可以在接下来一周内完成的小行动，让你更靠近你的价值观。")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)

                TextEditor(text: $viewModel.actionPlan)
                    .font(AppFont.body)
                    .frame(minHeight: 100)
                    .padding(AppSpacing.sm)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(AppTheme.border, lineWidth: 0.5)
                    )

                Text("例如：这周给妈妈打三次电话（体现「家庭」价值观）")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: AppSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color(hex: "8B6F47").opacity(0.6))
                    .frame(width: 100, height: 100)
                Image(systemName: "compass.drawing")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "8B6F47"))
            }
            .padding(.top, AppSpacing.xl)

            Text("价值观探索完成！")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)

            Text(viewModel.completionMessage)
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            // Top 5 summary
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("你的核心价值观")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                    if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                        HStack(spacing: AppSpacing.md) {
                            Text("\(index + 1)")
                                .font(AppFont.title1)
                                .foregroundColor(Color(hex: "8B6F47"))
                                .frame(width: 28)
                            Text(value.emoji)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(value.name)
                                    .font(AppFont.body.weight(.medium))
                                    .foregroundColor(AppTheme.textPrimary)
                                if let reflection = viewModel.valueReflections[valueId], !reflection.isEmpty {
                                    Text(reflection)
                                        .font(AppFont.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding(AppSpacing.sm)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Alignment rating
            VStack(spacing: AppSpacing.sm) {
                Text("行为与价值观一致性")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(Int(viewModel.alignmentRating))/10")
                    .font(AppFont.largeTitle)
                    .foregroundColor(Color(hex: "8B6F47"))
                Text(viewModel.alignmentDescription)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Action plan
            if !viewModel.actionPlan.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("你的行动方案")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(viewModel.actionPlan)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)
            }

            // Actions
            VStack(spacing: AppSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("重新探索")
                        .font(AppFont.body.weight(.medium).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(Color(hex: "8B6F47"))
                        .cornerRadius(AppRadius.md)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, AppSpacing.lg)
        }
    }

    // MARK: - Shared

    private var stepHeaderView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.currentStep.title)
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)
            Text(viewModel.currentStep.subtitle)
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var navigationButtons: some View {
        HStack(spacing: AppSpacing.md) {
            if viewModel.currentStep.rawValue > 0 {
                Button {
                    viewModel.goToPreviousStep()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("上一步")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(Color(hex: "8B6F47"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color(hex: "8B6F47").opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .actionPlan ? "完成探索" : "下一步")
                    Image(systemName: viewModel.currentStep == .actionPlan ? "checkmark" : "chevron.right")
                }
                .font(AppFont.body.weight(.medium).weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(canProceed ? Color(hex: "8B6F47") : AppTheme.textSecondary)
                .cornerRadius(AppRadius.md)
            }
            .disabled(!canProceed)
        }
    }

    private var canProceed: Bool {
        switch viewModel.currentStep {
        case .selectTen: return viewModel.canProceedSelect
        case .rankTopFive: return viewModel.canProceedRank
        case .reflectOnValues: return viewModel.canProceedReflect
        case .rateAlignment: return viewModel.canProceedRate
        case .actionPlan: return viewModel.canProceedAction
        case .completed: return true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCValuesExplorerView().environment(CCAppCoordinator())
    }
}
