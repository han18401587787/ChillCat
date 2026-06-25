//
//  CCCBTView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — CBT认知重构 View
//

import SwiftUI

// MARK: - CBT View

struct CCCBTView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCCBTViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Step progress indicator
                stepProgressBar

                // Current step content
                Group {
                    switch viewModel.currentStep {
                    case .recordThought:
                        step1RecordThought
                    case .identifyDistortions:
                        step2IdentifyDistortions
                    case .reframeThought:
                        step3ReframeThought
                    case .completed:
                        completionView
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                // Navigation buttons
                if viewModel.currentStep != .completed {
                    navigationButtons
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("CBT认知重构")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(AppTheme.primary)
            }
        }
    }

    // MARK: - Step Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    stepIndicator(step: step)
                }
            }

            // Step labels
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(AppFont.caption)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? AppTheme.primary : AppTheme.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    private func stepIndicator(step: CCCBTStep) -> some View {
        HStack(spacing: 0) {
            // Circle
            ZStack {
                Circle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue
                          ? AppTheme.primary : (step.rawValue == viewModel.currentStep.rawValue
                                             ? AppTheme.primary : AppTheme.border))
                    .frame(width: 28, height: 28)
                if step.rawValue < viewModel.currentStep.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step.rawValue + 1)")
                        .font(AppFont.caption.weight(.bold))
                        .foregroundColor(step.rawValue == viewModel.currentStep.rawValue ? .white : AppTheme.textSecondary)
                }
            }

            // Connector line
            if step.rawValue < CCCBTStep.completed.rawValue {
                Rectangle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue ? AppTheme.primary : AppTheme.border)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 1: Record Automatic Thought

    private var step1RecordThought: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader

            // Situation
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("情境描述")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("描述发生了什么具体事件？在什么时候、什么地方、和谁？")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                TextField("例如：今天开会时我的发言被同事打断了...", text: $viewModel.situationText, axis: .vertical)
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.sm)
                    .lineLimit(3...6)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Automatic thought
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("自动思维")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("当时脑海中自动浮现了什么想法？")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                TextEditor(text: $viewModel.automaticThought)
                    .font(AppFont.body)
                    .frame(minHeight: 100)
                    .padding(AppSpacing.sm)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(AppTheme.border, lineWidth: 0.5)
                    )
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Step 2: Identify Distortions

    private var step2IdentifyDistortions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("选择包含的认知扭曲")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("你的自动思维中可能包含多种认知扭曲，请选择所有适用的")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)

            // Distortion grid
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.sm), GridItem(.flexible(), spacing: AppSpacing.sm)],
                spacing: AppSpacing.sm
            ) {
                ForEach(CCCognitiveDistortion.all) { distortion in
                    distortionButton(distortion)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Selected distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("已选择 \(viewModel.selectedDistortions.count) 种认知扭曲")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                    FlowLayout(spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let distortion = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                HStack(spacing: 4) {
                                    Text(distortion.name)
                                        .font(AppFont.caption)
                                        .foregroundColor(AppTheme.softPurple)
                                    Button {
                                        viewModel.toggleDistortion(id)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.softPurple.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(AppTheme.softPurpleLight.opacity(0.3))
                                .cornerRadius(AppRadius.full)
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)
            }
        }
    }

    private func distortionButton(_ distortion: CCCognitiveDistortion) -> some View {
        let isSelected = viewModel.selectedDistortions.contains(distortion.id)
        return Button {
            CCHaptic.light()
            viewModel.toggleDistortion(distortion.id)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(distortion.name)
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                Text(distortion.description)
                    .font(AppFont.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.85) : AppTheme.textSecondary)
                    .lineLimit(2)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(isSelected ? AppTheme.softPurple : AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .stroke(isSelected ? AppTheme.softPurple : AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Reframe

    private var step3ReframeThought: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader

            // Emotion before
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("情绪强度（重构前）")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionBefore,
                    color: AppTheme.softPurple,
                    label: "重构前"
                )
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Balanced thought
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("重构合理思维")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("如果用更平衡、更客观的角度来看这件事，你会怎么想？有什么证据支持或反对这个自动思维？如果朋友遇到同样的事，你会对他说什么？")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                TextEditor(text: $viewModel.balancedThought)
                    .font(AppFont.body)
                    .frame(minHeight: 120)
                    .padding(AppSpacing.sm)
                    .background(AppTheme.softGreenLight.opacity(0.3))
                    .cornerRadius(AppRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(AppTheme.softGreen.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Emotion after
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("情绪强度（重构后）")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionAfter,
                    color: AppTheme.softGreen,
                    label: "重构后"
                )
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    private func emotionSliderRow(value: Binding<Double>, color: Color, label: String) -> some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("非常轻微")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text("\(Int(value.wrappedValue))/10")
                    .font(AppFont.title3)
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                Spacer()
                Text("非常强烈")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Slider(value: value, in: 1...10, step: 1)
                .tint(color)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: AppSpacing.xl) {
            // Success icon
            ZStack {
                Circle()
                    .fill(AppTheme.softGreenLight)
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.softGreen)
            }
            .padding(.top, AppSpacing.xl)

            Text("练习完成！")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)

            Text(viewModel.completionMessage)
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            // Emotion comparison
            VStack(spacing: AppSpacing.md) {
                Text("情绪变化")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: AppSpacing.xl) {
                    emotionStat(label: "重构前", value: Int(viewModel.emotionBefore), color: AppTheme.softPurple)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.textSecondary)
                    emotionStat(label: "重构后", value: Int(viewModel.emotionAfter), color: AppTheme.softGreen)
                }

                Text(viewModel.emotionChangeDescription)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Identified distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("识别的认知扭曲")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)
                    FlowLayout(spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let d = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                Text(d.name)
                                    .font(AppFont.caption)
                                    .foregroundColor(AppTheme.softPurple)
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, AppSpacing.xs)
                                    .background(AppTheme.softPurpleLight.opacity(0.3))
                                    .cornerRadius(AppRadius.full)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)
            }

            // Action buttons
            VStack(spacing: AppSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次练习")
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, AppSpacing.lg)
        }
    }

    // MARK: - Step Header

    private var stepHeader: some View {
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

    // MARK: - Navigation Buttons

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
                    .font(AppFont.body.weight(.medium))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .reframeThought ? "完成练习" : "下一步")
                    Image(systemName: viewModel.currentStep == .reframeThought ? "checkmark" : "chevron.right")
                }
                .font(AppFont.body.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(canProceed ? AppTheme.primary : AppTheme.textSecondary)
                .cornerRadius(AppRadius.md)
            }
            .disabled(!canProceed)
        }
    }

    private var canProceed: Bool {
        switch viewModel.currentStep {
        case .recordThought: return viewModel.canProceedFromStep1
        case .identifyDistortions: return viewModel.canProceedFromStep2
        case .reframeThought: return viewModel.canProceedFromStep3
        case .completed: return true
        }
    }

    // MARK: - Helpers

    private func emotionStat(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text("\(value)")
                .font(AppFont.largeTitle.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

// MARK: - Flow Layout

struct CBTFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCCBTView()
            .environment(CCAppCoordinator())
    }
}
