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
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCCBTViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
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
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
            .padding(.bottom, theme.spacing3XL)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("CBT认知重构")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(theme.primary)
            }
        }
    }

    // MARK: - Step Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: theme.spacingSM) {
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    stepIndicator(step: step)
                }
            }

            // Step labels
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(theme.fontCaption)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? theme.primary : theme.textMuted
                        )
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    private func stepIndicator(step: CCCBTStep) -> some View {
        HStack(spacing: 0) {
            // Circle
            ZStack {
                Circle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue
                          ? theme.primary : (step.rawValue == viewModel.currentStep.rawValue
                                             ? theme.primary : theme.divider))
                    .frame(width: 28, height: 28)
                if step.rawValue < viewModel.currentStep.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step.rawValue + 1)")
                        .font(theme.fontCaption.weight(.bold))
                        .foregroundColor(step.rawValue == viewModel.currentStep.rawValue ? .white : theme.textMuted)
                }
            }

            // Connector line
            if step.rawValue < CCCBTStep.completed.rawValue {
                Rectangle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue ? theme.primary : theme.divider)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 1: Record Automatic Thought

    private var step1RecordThought: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeader

            // Situation
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("情境描述")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Text("描述发生了什么具体事件？在什么时候、什么地方、和谁？")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)
                TextField("例如：今天开会时我的发言被同事打断了...", text: $viewModel.situationText, axis: .vertical)
                    .font(theme.fontBody)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusSM)
                    .lineLimit(3...6)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Automatic thought
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("自动思维")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Text("当时脑海中自动浮现了什么想法？")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)
                TextEditor(text: $viewModel.automaticThought)
                    .font(theme.fontBody)
                    .frame(minHeight: 100)
                    .padding(theme.spacingSM)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusSM)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radiusSM)
                            .stroke(theme.divider, lineWidth: 0.5)
                    )
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Step 2: Identify Distortions

    private var step2IdentifyDistortions: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeader

            VStack(alignment: .leading, spacing: theme.spacingMD) {
                Text("选择包含的认知扭曲")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Text("你的自动思维中可能包含多种认知扭曲，请选择所有适用的")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingLG)

            // Distortion grid
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: theme.spacingSM), GridItem(.flexible(), spacing: theme.spacingSM)],
                spacing: theme.spacingSM
            ) {
                ForEach(CCCognitiveDistortion.all) { distortion in
                    distortionButton(distortion)
                }
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.bottom, theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Selected distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("已选择 \(viewModel.selectedDistortions.count) 种认知扭曲")
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.textSecondary)
                    FlowLayout(spacing: theme.spacingSM) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let distortion = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                HStack(spacing: 4) {
                                    Text(distortion.name)
                                        .font(theme.fontCaption)
                                        .foregroundColor(theme.softPurple)
                                    Button {
                                        viewModel.toggleDistortion(id)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(theme.softPurple.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, theme.spacingSM)
                                .padding(.vertical, theme.spacingXS)
                                .background(theme.softPurpleLight.opacity(0.3))
                                .cornerRadius(theme.radiusFull)
                            }
                        }
                    }
                }
                .padding(theme.spacingLG)
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)
            }
        }
    }

    private func distortionButton(_ distortion: CCCognitiveDistortion) -> some View {
        let isSelected = viewModel.selectedDistortions.contains(distortion.id)
        return Button {
            CCHaptic.light()
            viewModel.toggleDistortion(distortion.id)
        } label: {
            VStack(alignment: .leading, spacing: theme.spacingXS) {
                HStack {
                    Text(distortion.name)
                        .font(theme.fontBody.weight(.medium))
                        .foregroundColor(isSelected ? .white : theme.textPrimary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                Text(distortion.description)
                    .font(theme.fontCaption)
                    .foregroundColor(isSelected ? .white.opacity(0.85) : theme.textMuted)
                    .lineLimit(2)
            }
            .padding(theme.spacingMD)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.radiusSM)
                    .fill(isSelected ? theme.softPurple : theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusSM)
                    .stroke(isSelected ? theme.softPurple : theme.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Reframe

    private var step3ReframeThought: some View {
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            stepHeader

            // Emotion before
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("情绪强度（重构前）")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionBefore,
                    color: theme.softPurple,
                    label: "重构前"
                )
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Balanced thought
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("重构合理思维")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Text("如果用更平衡、更客观的角度来看这件事，你会怎么想？有什么证据支持或反对这个自动思维？如果朋友遇到同样的事，你会对他说什么？")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)
                TextEditor(text: $viewModel.balancedThought)
                    .font(theme.fontBody)
                    .frame(minHeight: 120)
                    .padding(theme.spacingSM)
                    .background(theme.softGreenLight.opacity(0.3))
                    .cornerRadius(theme.radiusSM)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radiusSM)
                            .stroke(theme.softGreen.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Emotion after
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("情绪强度（重构后）")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionAfter,
                    color: theme.softGreen,
                    label: "重构后"
                )
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    private func emotionSliderRow(value: Binding<Double>, color: Color, label: String) -> some View {
        VStack(spacing: theme.spacingSM) {
            HStack {
                Text("非常轻微")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
                Spacer()
                Text("\(Int(value.wrappedValue))/10")
                    .font(theme.fontH3)
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                Spacer()
                Text("非常强烈")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
            }
            Slider(value: value, in: 1...10, step: 1)
                .tint(color)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: theme.spacingXL) {
            // Success icon
            ZStack {
                Circle()
                    .fill(theme.softGreenLight)
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.softGreen)
            }
            .padding(.top, theme.spacing2XL)

            Text("练习完成！")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)

            Text(viewModel.completionMessage)
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingLG)

            // Emotion comparison
            VStack(spacing: theme.spacingMD) {
                Text("情绪变化")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                HStack(spacing: theme.spacing2XL) {
                    emotionStat(label: "重构前", value: Int(viewModel.emotionBefore), color: theme.softPurple)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(theme.textMuted)
                    emotionStat(label: "重构后", value: Int(viewModel.emotionAfter), color: theme.softGreen)
                }

                Text(viewModel.emotionChangeDescription)
                    .font(theme.fontBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Identified distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("识别的认知扭曲")
                        .font(theme.fontH3)
                        .foregroundColor(theme.textPrimary)
                    FlowLayout(spacing: theme.spacingSM) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let d = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                Text(d.name)
                                    .font(theme.fontCaption)
                                    .foregroundColor(theme.softPurple)
                                    .padding(.horizontal, theme.spacingSM)
                                    .padding(.vertical, theme.spacingXS)
                                    .background(theme.softPurpleLight.opacity(0.3))
                                    .cornerRadius(theme.radiusFull)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacingLG)
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)
            }

            // Action buttons
            VStack(spacing: theme.spacingSM) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次练习")
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingMD)
                        .background(theme.primary)
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

    // MARK: - Step Header

    private var stepHeader: some View {
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

    // MARK: - Navigation Buttons

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
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.primary.opacity(0.1))
                    .cornerRadius(theme.radiusMD)
                }
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .reframeThought ? "完成练习" : "下一步")
                    Image(systemName: viewModel.currentStep == .reframeThought ? "checkmark" : "chevron.right")
                }
                .font(theme.fontBodyL.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacingMD)
                .background(canProceed ? theme.primary : theme.textMuted)
                .cornerRadius(theme.radiusMD)
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
        VStack(spacing: theme.spacingXS) {
            Text("\(value)")
                .font(theme.fontDisplay)
                .foregroundColor(color)
            Text(label)
                .font(theme.fontCaption)
                .foregroundColor(theme.textMuted)
        }
    }
}

// MARK: - Flow Layout


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
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}
