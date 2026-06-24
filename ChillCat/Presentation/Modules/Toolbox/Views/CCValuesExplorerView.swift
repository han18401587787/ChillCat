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
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCValuesExplorerViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
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
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
            .padding(.bottom, theme.spacing3XL)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("价值观探索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(theme.primary)
            }
        }
    }

    // MARK: - Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: theme.spacingSM) {
            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Circle()
                        .fill(step.rawValue < viewModel.currentStep.rawValue
                              ? theme.warm : (step.rawValue == viewModel.currentStep.rawValue
                                              ? theme.warm : theme.divider))
                        .frame(width: 10, height: 10)
                    if step.rawValue < CCValuesStep.completed.rawValue {
                        Rectangle()
                            .fill(step.rawValue < viewModel.currentStep.rawValue ? theme.warm : theme.divider)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(theme.fontLabel)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? theme.warm : theme.textMuted
                        )
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Step 1: Select Values

    private var stepSelectValues: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeaderView

            Text("已选择 \(viewModel.selectedValues.count)/10")
                .font(theme.fontBody)
                .foregroundColor(
                    viewModel.selectedValues.count >= 5 ? theme.softGreen : theme.textMuted
                )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.spacingSM),
                    GridItem(.flexible(), spacing: theme.spacingSM),
                ],
                spacing: theme.spacingSM
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
            VStack(spacing: theme.spacingXS) {
                Text(value.emoji)
                    .font(.system(size: 28))
                Text(value.name)
                    .font(theme.fontBodyS.weight(.medium))
                    .foregroundColor(isSelected ? .white : theme.textPrimary)
                Text(value.description)
                    .font(theme.fontLabel)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : theme.textMuted)
                    .lineLimit(1)
            }
            .padding(theme.spacingMD)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: theme.radiusSM)
                    .fill(isSelected ? theme.warm : theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusSM)
                    .stroke(isSelected ? theme.warm : theme.divider, lineWidth: 1)
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
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeaderView

            Text("拖拽排列最重要的5个价值观（从上到下为最重要到最不重要）")
                .font(theme.fontBodyS)
                .foregroundColor(theme.textSecondary)

            // Show all selected values, let user pick 5 to rank
            VStack(spacing: theme.spacingSM) {
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
                            HStack(spacing: theme.spacingMD) {
                                // Rank number or selection indicator
                                if let rank = rank {
                                    ZStack {
                                        Circle()
                                            .fill(theme.warm)
                                            .frame(width: 28, height: 28)
                                        Text("\(rank)")
                                            .font(theme.fontBodyS.weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Circle()
                                        .stroke(theme.divider, lineWidth: 1.5)
                                        .frame(width: 28, height: 28)
                                }

                                Text(value.emoji)
                                    .font(.system(size: 22))
                                Text(value.name)
                                    .font(theme.fontBody)
                                    .foregroundColor(isInTopFive ? theme.textPrimary : theme.textMuted)
                                Spacer()
                                Image(systemName: isInTopFive ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isInTopFive ? theme.warm : theme.textMuted)
                                    .font(.system(size: 20))
                            }
                            .padding(theme.spacingMD)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radiusSM)
                                    .fill(isInTopFive ? theme.warmMuted.opacity(0.5) : theme.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Display current ranking
            if !viewModel.rankedValues.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("当前排序")
                        .font(theme.fontH3)
                        .foregroundColor(theme.textPrimary)
                    Text("使用右侧手柄拖拽调整顺序")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)

                    ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                        if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                            HStack(spacing: theme.spacingMD) {
                                Text("\(index + 1)")
                                    .font(theme.fontH2)
                                    .foregroundColor(theme.warm)
                                    .frame(width: 28)
                                Text(value.emoji)
                                    .font(.system(size: 24))
                                Text(value.name)
                                    .font(theme.fontBody.weight(.medium))
                                    .foregroundColor(theme.textPrimary)
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(theme.textMuted)
                            }
                            .padding(theme.spacingMD)
                            .background(theme.cardBackground)
                            .cornerRadius(theme.radiusSM)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Reflect

    private var stepReflectValues: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeaderView

            ForEach(viewModel.rankedValues, id: \.self) { valueId in
                if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                    VStack(alignment: .leading, spacing: theme.spacingSM) {
                        HStack {
                            Text(value.emoji)
                                .font(.system(size: 20))
                            Text(value.name)
                                .font(theme.fontH3)
                                .foregroundColor(theme.textPrimary)
                        }

                        Text("我在做什么时体现了这个价值？")
                            .font(theme.fontBodyS)
                            .foregroundColor(theme.textSecondary)

                        TextField(
                            "例如：当我和家人一起吃饭聊天时...",
                            text: Binding(
                                get: { viewModel.valueReflections[valueId] ?? "" },
                                set: { viewModel.setReflection(for: valueId, text: $0) }
                            ),
                            axis: .vertical
                        )
                        .font(theme.fontBody)
                        .padding(theme.spacingMD)
                        .background(theme.surface)
                        .cornerRadius(theme.radiusSM)
                        .lineLimit(2...4)
                    }
                    .padding(theme.spacingLG)
                    .background(theme.cardBackground)
                    .cornerRadius(theme.radiusMD)
                }
            }
        }
    }

    // MARK: - Step 4: Rate Alignment

    private var stepRateAlignment: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeaderView

            VStack(alignment: .leading, spacing: theme.spacingMD) {
                Text("当前行为与价值观的一致性")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                Text("1 = 完全不一致，10 = 完全一致")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)

                HStack {
                    Text("不一致")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                    Spacer()
                    Text("\(Int(viewModel.alignmentRating))/10")
                        .font(theme.fontH1)
                        .foregroundColor(theme.warm)
                    Spacer()
                    Text("完全一致")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                }

                Slider(value: $viewModel.alignmentRating, in: 1...10, step: 1)
                    .tint(theme.warm)

                if !viewModel.alignmentDescription.isEmpty {
                    Text(viewModel.alignmentDescription)
                        .font(theme.fontBody)
                        .foregroundColor(theme.textSecondary)
                        .padding(.top, theme.spacingSM)
                }
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Step 5: Action Plan

    private var stepActionPlan: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeaderView

            VStack(alignment: .leading, spacing: theme.spacingMD) {
                Text("制定一个小行动")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                Text("想一个具体的、可以在接下来一周内完成的小行动，让你更靠近你的价值观。")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)

                TextEditor(text: $viewModel.actionPlan)
                    .font(theme.fontBody)
                    .frame(minHeight: 100)
                    .padding(theme.spacingSM)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusSM)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radiusSM)
                            .stroke(theme.divider, lineWidth: 0.5)
                    )

                Text("例如：这周给妈妈打三次电话（体现「家庭」价值观）")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: theme.spacingXL) {
            ZStack {
                Circle()
                    .fill(theme.warmMuted)
                    .frame(width: 100, height: 100)
                Image(systemName: "compass.drawing")
                    .font(.system(size: 44))
                    .foregroundColor(theme.warm)
            }
            .padding(.top, theme.spacing2XL)

            Text("价值观探索完成！")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)

            Text(viewModel.completionMessage)
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingLG)

            // Top 5 summary
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("你的核心价值观")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                    if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                        HStack(spacing: theme.spacingMD) {
                            Text("\(index + 1)")
                                .font(theme.fontH2)
                                .foregroundColor(theme.warm)
                                .frame(width: 28)
                            Text(value.emoji)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(value.name)
                                    .font(theme.fontBody.weight(.medium))
                                    .foregroundColor(theme.textPrimary)
                                if let reflection = viewModel.valueReflections[valueId], !reflection.isEmpty {
                                    Text(reflection)
                                        .font(theme.fontCaption)
                                        .foregroundColor(theme.textSecondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding(theme.spacingSM)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Alignment rating
            VStack(spacing: theme.spacingSM) {
                Text("行为与价值观一致性")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
                Text("\(Int(viewModel.alignmentRating))/10")
                    .font(theme.fontH1)
                    .foregroundColor(theme.warm)
                Text(viewModel.alignmentDescription)
                    .font(theme.fontBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Action plan
            if !viewModel.actionPlan.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("你的行动方案")
                        .font(theme.fontH3)
                        .foregroundColor(theme.textPrimary)
                    Text(viewModel.actionPlan)
                        .font(theme.fontBody)
                        .foregroundColor(theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacingLG)
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)
            }

            // Actions
            VStack(spacing: theme.spacingSM) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("重新探索")
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingMD)
                        .background(theme.warm)
                        .cornerRadius(theme.radiusMD)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(theme.fontBodyL)
                        .foregroundColor(theme.textSecondary)
                }
            }
            .padding(.top, theme.spacingLG)
        }
    }

    // MARK: - Shared

    private var stepHeaderView: some View {
        VStack(alignment: .leading, spacing: theme.spacingXS) {
            Text(viewModel.currentStep.title)
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)
            Text(viewModel.currentStep.subtitle)
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var navigationButtons: some View {
        HStack(spacing: theme.spacingMD) {
            if viewModel.currentStep.rawValue > 0 {
                Button {
                    viewModel.goToPreviousStep()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("上一步")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.warm)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.warm.opacity(0.1))
                    .cornerRadius(theme.radiusMD)
                }
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .actionPlan ? "完成探索" : "下一步")
                    Image(systemName: viewModel.currentStep == .actionPlan ? "checkmark" : "chevron.right")
                }
                .font(theme.fontBodyL.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacingMD)
                .background(canProceed ? theme.warm : theme.textMuted)
                .cornerRadius(theme.radiusMD)
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
        CCValuesExplorerView()
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}
