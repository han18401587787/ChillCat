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
            VStack(spacing: XuanSpacing.xl) {
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
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.sm)
            .padding(.bottom, XuanSpacing.xl)
        }
        .background(Color.xuanApricotBg.ignoresSafeArea())
        .navigationTitle("CBT认知重构")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(Color.xuanApricot)
                    .accessibilityIdentifier("cbt_close")
            }
        }
    }

    // MARK: - Step Progress Bar

    private var stepProgressBar: some View {
        VStack(spacing: XuanSpacing.sm) {
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    stepIndicator(step: step)
                }
            }

            // Step labels
            HStack(spacing: 0) {
                ForEach(CCCBTStep.allCases.dropLast(), id: \.rawValue) { step in
                    Text(step.title)
                        .font(XuanFont.bodyM)
                        .foregroundColor(
                            step.rawValue <= viewModel.currentStep.rawValue
                                ? Color.xuanApricot : Color.xuanTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    private func stepIndicator(step: CCCBTStep) -> some View {
        HStack(spacing: 0) {
            // Circle
            ZStack {
                Circle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue
                          ? Color.xuanApricot : (step.rawValue == viewModel.currentStep.rawValue
                                             ? Color.xuanApricot : Color.xuanBorder))
                    .frame(width: 28, height: 28)
                if step.rawValue < viewModel.currentStep.rawValue {
                    Image("home_checkin")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step.rawValue + 1)")
                        .font(XuanFont.bodyM)
                        .foregroundColor(step.rawValue == viewModel.currentStep.rawValue ? .white : Color.xuanTextSecondary)
                }
            }

            // Connector line
            if step.rawValue < CCCBTStep.completed.rawValue {
                Rectangle()
                    .fill(step.rawValue < viewModel.currentStep.rawValue ? Color.xuanApricot : Color.xuanBorder)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 1: Record Automatic Thought

    private var step1RecordThought: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeader

            // Situation
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("情境描述")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("描述发生了什么具体事件？在什么时候、什么地方、和谁？")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                TextField("例如：今天开会时我的发言被同事打断了...", text: $viewModel.situationText, axis: .vertical)
                    .font(XuanFont.bodyL)
                    .padding(XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.sm)
                    .lineLimit(3...6)
                    .accessibilityIdentifier("cbt_situation_text")
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Automatic thought
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("自动思维")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("当时脑海中自动浮现了什么想法？")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                TextEditor(text: $viewModel.automaticThought)
                    .font(XuanFont.bodyL)
                    .frame(minHeight: 100)
                    .padding(XuanSpacing.sm)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: XuanRadius.sm)
                            .stroke(Color.xuanBorder, lineWidth: 0.5)
                    )
                    .accessibilityIdentifier("cbt_automatic_thought")
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
        }
    }

    // MARK: - Step 2: Identify Distortions

    private var step2IdentifyDistortions: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeader

            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                Text("选择包含的认知扭曲")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("你的自动思维中可能包含多种认知扭曲，请选择所有适用的")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.lg)

            // Distortion grid
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: XuanSpacing.sm), GridItem(.flexible(), spacing: XuanSpacing.sm)],
                spacing: XuanSpacing.sm
            ) {
                ForEach(CCCognitiveDistortion.all) { distortion in
                    distortionButton(distortion)
                }
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.bottom, XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Selected distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("已选择 \(viewModel.selectedDistortions.count) 种认知扭曲")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    FlowLayout(spacing: XuanSpacing.sm) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let distortion = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                HStack(spacing: 4) {
                                    Text(distortion.name)
                                        .font(XuanFont.bodyM)
                                        .foregroundColor(Color(hex: "A085C6").opacity(0.5))
                                    Button {
                                        viewModel.toggleDistortion(id)
                                    } label: {
                                        Image("common_close")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "A085C6").opacity(0.5).opacity(0.6))
                                    }
                                    .accessibilityIdentifier("cbt_remove_distortion_\(id)")
                                }
                                .padding(.horizontal, XuanSpacing.sm)
                                .padding(.vertical, XuanSpacing.xs)
                                .background(Color(hex: "A085C6").opacity(0.25).opacity(0.3))
                                .cornerRadius(XuanRadius.full)
                            }
                        }
                    }
                }
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)
            }
        }
    }

    private func distortionButton(_ distortion: CCCognitiveDistortion) -> some View {
        let isSelected = viewModel.selectedDistortions.contains(distortion.id)
        return Button {
            CCHaptic.light()
            viewModel.toggleDistortion(distortion.id)
        } label: {
            VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                HStack {
                    Text(distortion.name)
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(isSelected ? .white : Color.xuanTextPrimary)
                    Spacer()
                    if isSelected {
                        Image("home_checkin")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                Text(distortion.description)
                    .font(XuanFont.bodyM)
                    .foregroundColor(isSelected ? .white.opacity(0.85) : Color.xuanTextSecondary)
                    .lineLimit(2)
            }
            .padding(XuanSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.sm)
                    .fill(isSelected ? Color(hex: "A085C6").opacity(0.5) : Color.xuanSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.sm)
                    .stroke(isSelected ? Color(hex: "A085C6").opacity(0.5) : Color.xuanBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("cbt_distortion_\(distortion.id)")
    }

    // MARK: - Step 3: Reframe

    private var step3ReframeThought: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.lg) {
            stepHeader

            // Emotion before
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("情绪强度（重构前）")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionBefore,
                    color: Color(hex: "A085C6").opacity(0.5),
                    label: "重构前"
                )
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Balanced thought
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("重构合理思维")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("如果用更平衡、更客观的角度来看这件事，你会怎么想？有什么证据支持或反对这个自动思维？如果朋友遇到同样的事，你会对他说什么？")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                TextEditor(text: $viewModel.balancedThought)
                    .font(XuanFont.bodyL)
                    .frame(minHeight: 120)
                    .padding(XuanSpacing.sm)
                    .background(Color.xuanSuccess.opacity(0.25).opacity(0.3))
                    .cornerRadius(XuanRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: XuanRadius.sm)
                            .stroke(Color.xuanSuccess.opacity(0.4), lineWidth: 1)
                    )
                    .accessibilityIdentifier("cbt_balanced_thought")
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Emotion after
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("情绪强度（重构后）")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                emotionSliderRow(
                    value: $viewModel.emotionAfter,
                    color: Color.xuanSuccess,
                    label: "重构后"
                )
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)
        }
    }

    private func emotionSliderRow(value: Binding<Double>, color: Color, label: String) -> some View {
        VStack(spacing: XuanSpacing.sm) {
            HStack {
                Text("非常轻微")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                Spacer()
                Text("\(Int(value.wrappedValue))/10")
                    .font(XuanFont.h3)
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                Spacer()
                Text("非常强烈")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Slider(value: value, in: 1...10, step: 1)
                .tint(color)
                .accessibilityIdentifier("cbt_emotion_\(label)_slider")
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: XuanSpacing.xl) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.xuanSuccess.opacity(0.25))
                    .frame(width: 100, height: 100)
                Image("home_checkin")
                    .font(.system(size: 48))
                    .foregroundColor(Color.xuanSuccess)
            }
            .padding(.top, XuanSpacing.xl)

            Text("练习完成！")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text(viewModel.completionMessage)
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.lg)

            // Emotion comparison
            VStack(spacing: XuanSpacing.md) {
                Text("情绪变化")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                HStack(spacing: XuanSpacing.xl) {
                    emotionStat(label: "重构前", value: Int(viewModel.emotionBefore), color: Color(hex: "A085C6").opacity(0.5))
                    Image("common_more")
                        .font(.system(size: 20))
                        .foregroundColor(Color.xuanTextSecondary)
                    emotionStat(label: "重构后", value: Int(viewModel.emotionAfter), color: Color.xuanSuccess)
                }

                Text(viewModel.emotionChangeDescription)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Identified distortions summary
            if !viewModel.selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("识别的认知扭曲")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    FlowLayout(spacing: XuanSpacing.sm) {
                        ForEach(Array(viewModel.selectedDistortions), id: \.self) { id in
                            if let d = CCCognitiveDistortion.all.first(where: { $0.id == id }) {
                                Text(d.name)
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(Color(hex: "A085C6").opacity(0.5))
                                    .padding(.horizontal, XuanSpacing.sm)
                                    .padding(.vertical, XuanSpacing.xs)
                                    .background(Color(hex: "A085C6").opacity(0.25).opacity(0.3))
                                    .cornerRadius(XuanRadius.full)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)
            }

            // Action buttons
            VStack(spacing: XuanSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次练习")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("cbt_retry")

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .accessibilityIdentifier("cbt_back")
            }
            .padding(.top, XuanSpacing.lg)
        }
    }

    // MARK: - Step Header

    private var stepHeader: some View {
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

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: XuanSpacing.md) {
            if viewModel.currentStep.rawValue > 0 {
                Button {
                    viewModel.goToPreviousStep()
                } label: {
                    HStack {
                        Image("common_back")
                        Text("上一步")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanApricot)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot.opacity(0.1))
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("cbt_prev_step")
            }

            Button {
                viewModel.goToNextStep()
            } label: {
                HStack {
                    Text(viewModel.currentStep == .reframeThought ? "完成练习" : "下一步")
                    CCIconMapper.image(for: viewModel.currentStep == .reframeThought ? "checkmark" : "chevron.right")
                }
                .font(XuanFont.bodyLMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, XuanSpacing.md)
                .background(canProceed ? Color.xuanApricot : Color.xuanTextSecondary)
                .cornerRadius(XuanRadius.md)
            }
            .disabled(!canProceed)
            .accessibilityIdentifier("cbt_next_step")
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
        VStack(spacing: XuanSpacing.xs) {
            Text("\(value)")
                .font(XuanFont.h1)
                .foregroundColor(color)
            Text(label)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
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
