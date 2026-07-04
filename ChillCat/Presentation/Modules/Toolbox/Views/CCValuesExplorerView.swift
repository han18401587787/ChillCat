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
            VStack(spacing: XuanSpacing.xl) {
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
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.sm)
            .padding(.bottom, XuanSpacing.xl)
        }
        .background(Color.xuanApricotBg.ignoresSafeArea())
        .navigationTitle("价值观探索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(Color.xuanApricot)
            }
        }
    }

    // MARK: - Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: XuanSpacing.sm) {
            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Circle()
                        .fill(step.rawValue < viewModel.currentStep.rawValue
                              ? Color.xuanApricotDark : (step.rawValue == viewModel.currentStep.rawValue
                                              ? Color.xuanApricotDark : Color.xuanBorder))
                        .frame(width: 10, height: 10)
                    if step.rawValue < CCValuesStep.completed.rawValue {
                        Rectangle()
                            .fill(step.rawValue < viewModel.currentStep.rawValue ? Color.xuanApricotDark : Color.xuanBorder)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            HStack(spacing: 0) {
                ForEach(CCValuesStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(XuanFont.bodyM)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? Color.xuanApricotDark : Color.xuanTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Step 1: Select Values

    private var stepSelectValues: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeaderView

            Text("已选择 \(viewModel.selectedValues.count)/10")
                .font(XuanFont.bodyL)
                .foregroundColor(
                    viewModel.selectedValues.count >= 5 ? Color.xuanMint : Color.xuanTextSecondary
                )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                ],
                spacing: XuanSpacing.sm
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
            VStack(spacing: XuanSpacing.xs) {
                Text(value.emoji)
                    .font(.system(size: 28))
                Text(value.name)
                    .font(XuanFont.bodyS.weight(.medium))
                    .foregroundColor(isSelected ? .white : Color.xuanTextPrimary)
                Text(value.description)
                    .font(XuanFont.bodyM)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : Color.xuanTextSecondary)
                    .lineLimit(1)
            }
            .padding(XuanSpacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.sm)
                    .fill(isSelected ? Color.xuanApricotDark : Color.xuanSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.sm)
                    .stroke(isSelected ? Color.xuanApricotDark : Color.xuanBorder, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image("home_checkin")
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
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeaderView

            Text("拖拽排列最重要的5个价值观（从上到下为最重要到最不重要）")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)

            // Show all selected values, let user pick 5 to rank
            VStack(spacing: XuanSpacing.sm) {
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
                            HStack(spacing: XuanSpacing.md) {
                                // Rank number or selection indicator
                                if let rank = rank {
                                    ZStack {
                                        Circle()
                                            .fill(Color.xuanApricotDark)
                                            .frame(width: 28, height: 28)
                                        Text("\(rank)")
                                            .font(XuanFont.bodyS.weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Circle()
                                        .stroke(Color.xuanBorder, lineWidth: 1.5)
                                        .frame(width: 28, height: 28)
                                }

                                Text(value.emoji)
                                    .font(.system(size: 22))
                                Text(value.name)
                                    .font(XuanFont.bodyL)
                                    .foregroundColor(isInTopFive ? Color.xuanTextPrimary : Color.xuanTextSecondary)
                                Spacer()
                                Image(systemName: isInTopFive ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isInTopFive ? Color.xuanApricotDark : Color.xuanTextSecondary)
                                    .font(.system(size: 20))
                            }
                            .padding(XuanSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: XuanRadius.sm)
                                    .fill(isInTopFive ? Color.xuanApricotDark.opacity(0.6).opacity(0.5) : Color.xuanSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Display current ranking
            if !viewModel.rankedValues.isEmpty {
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("当前排序")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text("使用右侧手柄拖拽调整顺序")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)

                    ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                        if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                            HStack(spacing: XuanSpacing.md) {
                                Text("\(index + 1)")
                                    .font(XuanFont.h1)
                                    .foregroundColor(Color.xuanApricotDark)
                                    .frame(width: 28)
                                Text(value.emoji)
                                    .font(.system(size: 24))
                                Text(value.name)
                                    .font(XuanFont.bodyLMedium)
                                    .foregroundColor(Color.xuanTextPrimary)
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(Color.xuanTextSecondary)
                            }
                            .padding(XuanSpacing.md)
                            .background(Color.xuanWhite)
                            .cornerRadius(XuanRadius.sm)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Reflect

    private var stepReflectValues: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeaderView

            ForEach(viewModel.rankedValues, id: \.self) { valueId in
                if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                    VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                        HStack {
                            Text(value.emoji)
                                .font(.system(size: 20))
                            Text(value.name)
                                .font(XuanFont.h3)
                                .foregroundColor(Color.xuanTextPrimary)
                        }

                        Text("我在做什么时体现了这个价值？")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)

                        TextField(
                            "例如：当我和家人一起吃饭聊天时...",
                            text: Binding(
                                get: { viewModel.valueReflections[valueId] ?? "" },
                                set: { viewModel.setReflection(for: valueId, text: $0) }
                            ),
                            axis: .vertical
                        )
                        .font(XuanFont.bodyL)
                        .padding(XuanSpacing.md)
                        .background(Color.xuanSurface)
                        .cornerRadius(XuanRadius.sm)
                        .lineLimit(2...4)
                    }
                    .padding(XuanSpacing.lg)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.md)
                }
            }
        }
    }

    // MARK: - Step 4: Rate Alignment

    private var stepRateAlignment: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeaderView

            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                Text("当前行为与价值观的一致性")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                Text("1 = 完全不一致，10 = 完全一致")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)

                HStack {
                    Text("不一致")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text("\(Int(viewModel.alignmentRating))/10")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanApricotDark)
                    Spacer()
                    Text("完全一致")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Slider(value: $viewModel.alignmentRating, in: 1...10, step: 1)
                    .tint(Color.xuanApricotDark)

                if !viewModel.alignmentDescription.isEmpty {
                    Text(viewModel.alignmentDescription)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                        .padding(.top, XuanSpacing.sm)
                }
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
        }
    }

    // MARK: - Step 5: Action Plan

    private var stepActionPlan: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeaderView

            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                Text("制定一个小行动")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                Text("想一个具体的、可以在接下来一周内完成的小行动，让你更靠近你的价值观。")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)

                TextEditor(text: $viewModel.actionPlan)
                    .font(XuanFont.bodyL)
                    .frame(minHeight: 100)
                    .padding(XuanSpacing.sm)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: XuanRadius.sm)
                            .stroke(Color.xuanBorder, lineWidth: 0.5)
                    )

                Text("例如：这周给妈妈打三次电话（体现「家庭」价值观）")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: XuanSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.xuanApricotDark.opacity(0.6))
                    .frame(width: 100, height: 100)
                Image(systemName: "compass.drawing")
                    .font(.system(size: 44))
                    .foregroundColor(Color.xuanApricotDark)
            }
            .padding(.top, XuanSpacing.xl)

            Text("价值观探索完成！")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text(viewModel.completionMessage)
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.lg)

            // Top 5 summary
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("你的核心价值观")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                ForEach(Array(viewModel.rankedValues.enumerated()), id: \.element) { index, valueId in
                    if let value = CCValueCard.all.first(where: { $0.id == valueId }) {
                        HStack(spacing: XuanSpacing.md) {
                            Text("\(index + 1)")
                                .font(XuanFont.h1)
                                .foregroundColor(Color.xuanApricotDark)
                                .frame(width: 28)
                            Text(value.emoji)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(value.name)
                                    .font(XuanFont.bodyLMedium)
                                    .foregroundColor(Color.xuanTextPrimary)
                                if let reflection = viewModel.valueReflections[valueId], !reflection.isEmpty {
                                    Text(reflection)
                                        .font(XuanFont.bodyM)
                                        .foregroundColor(Color.xuanTextSecondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding(XuanSpacing.sm)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Alignment rating
            VStack(spacing: XuanSpacing.sm) {
                Text("行为与价值观一致性")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                Text("\(Int(viewModel.alignmentRating))/10")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanApricotDark)
                Text(viewModel.alignmentDescription)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Action plan
            if !viewModel.actionPlan.isEmpty {
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("你的行动方案")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(viewModel.actionPlan)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)
            }

            // Actions
            VStack(spacing: XuanSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("重新探索")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanApricotDark)
                        .cornerRadius(XuanRadius.md)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
            .padding(.top, XuanSpacing.lg)
        }
    }

    // MARK: - Shared

    private var stepHeaderView: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.xs) {
            Text(viewModel.currentStep.title)
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
            Text(viewModel.currentStep.subtitle)
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var navigationButtons: some View {
        HStack(spacing: XuanSpacing.md) {
            if viewModel.currentStep.rawValue > 0 {
                Button {
                    viewModel.goToPreviousStep()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("上一步")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanApricotDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricotDark.opacity(0.1))
                    .cornerRadius(XuanRadius.md)
                }
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .actionPlan ? "完成探索" : "下一步")
                    Image(systemName: viewModel.currentStep == .actionPlan ? "checkmark" : "chevron.right")
                }
                .font(XuanFont.bodyLMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, XuanSpacing.md)
                .background(canProceed ? Color.xuanApricotDark : Color.xuanTextSecondary)
                .cornerRadius(XuanRadius.md)
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
