//
//  CCEmotionRecordView.swift
//  绪安 - 情绪记录页
//
//  设计规范: 绪安设计系统 v3.0
//  布局: 大标题 → 6情绪网格(2×3) → 语音输入按钮 → 情绪强度滑块 → 继续按钮

import SwiftUI

// MARK: - 情绪选项模型
struct EmotionOption: Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let color: Color
    let bgColor: Color
    let textColor: Color

    init(id: Int, name: String, emoji: String, color: Color) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.bgColor = color.opacity(0.12)
        self.textColor = color
    }
}

// MARK: - CCEmotionRecordView

struct CCEmotionRecordView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    @State private var selectedEmotion: Int? = nil
    @State private var intensity: Double = 5
    @State private var isVoiceRecording = false
    @State private var animateEntrance = false

    // 6个情绪选项 (2行×3列)
    private let emotions: [EmotionOption] = [
        EmotionOption(id: 0, name: "平静", emoji: "😌", color: Color.xuanMint),
        EmotionOption(id: 1, name: "愉悦", emoji: "😊", color: Color.xuanApricot),
        EmotionOption(id: 2, name: "焦虑", emoji: "😰", color: Color(hex: "A085C6")),
        EmotionOption(id: 3, name: "低落", emoji: "😢", color: Color.xuanInfo),
        EmotionOption(id: 4, name: "愤怒", emoji: "😤", color: Color.xuanDanger),
        EmotionOption(id: 5, name: "疲惫", emoji: "😴", color: Color.xuanTextTertiary),
    ]

    private var intensityColor: Color {
        switch Int(intensity) {
        case 0...3: return Color.xuanMint
        case 4...6: return Color.xuanApricotDark
        case 7...8: return Color.xuanWarning
        case 9...10: return Color.xuanDanger
        default: return Color.xuanTextTertiary
        }
    }

    private var intensityLabel: String {
        switch Int(intensity) {
        case 0...2: return "很轻微"
        case 3...4: return "轻微"
        case 5...6: return "中等"
        case 7...8: return "较强"
        case 9...10: return "非常强烈"
        default: return ""
        }
    }

    private var canProceed: Bool {
        selectedEmotion != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 1. 标题区
                titleSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 2. 情绪选择区 (2行×3列)
                emotionGridSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 3. 语音输入按钮
                voiceInputSection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 4. 情绪强度滑块
                intensitySection
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)

                // 5. 继续按钮
                continueButton
                    .opacity(animateEntrance ? 1 : 0)
                    .offset(y: animateEntrance ? 0 : 20)
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateEntrance = true
            }
        }
    }

    // MARK: - 1. 标题区
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.xs) {
            Text("此刻的感受")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("选择最贴近你此刻心情的情绪")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2. 情绪选择网格 (2行×3列)
    private var emotionGridSection: some View {
        VStack(spacing: XuanSpacing.md) {
            ForEach(0..<2) { row in
                HStack(spacing: XuanSpacing.md) {
                    ForEach(0..<3) { col in
                        let index = row * 3 + col
                        emotionCell(emotions[index])
                    }
                }
            }
        }
    }

    private func emotionCell(_ emotion: EmotionOption) -> some View {
        let isSelected = selectedEmotion == emotion.id

        return Button(action: {
            selectedEmotion = emotion.id
        }) {
            VStack(spacing: XuanSpacing.sm) {
                Text(emotion.emoji)
                    .font(.system(size: 36))

                Text(emotion.name)
                    .font(XuanFont.bodyM)
                    .foregroundColor(isSelected ? .white : emotion.textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .fill(isSelected ? emotion.color : emotion.bgColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(
                        isSelected ? emotion.color : emotion.color.opacity(0.25),
                        lineWidth: isSelected ? 0 : 1.5
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    // MARK: - 3. 语音输入区
    private var voiceInputSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("或通过语音表达")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextTertiary)

            Button(action: {
                isVoiceRecording.toggle()
                // TODO: 接入语音识别
            }) {
                ZStack {
                    Circle()
                        .fill(
                            isVoiceRecording
                                ? Color.xuanDanger.opacity(0.12)
                                : Color.xuanApricot.opacity(0.12)
                        )
                        .frame(width: 88, height: 88)

                    // 录音脉冲动画
                    if isVoiceRecording {
                        Circle()
                            .stroke(Color.xuanDanger.opacity(0.3), lineWidth: 2)
                            .frame(width: 88, height: 88)
                            .scaleEffect(isVoiceRecording ? 1.3 : 1.0)
                            .opacity(isVoiceRecording ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                                value: isVoiceRecording
                            )
                    }

                    VStack(spacing: XuanSpacing.xs) {
                        CCIconMapper.image(for: isVoiceRecording ? "waveform" : "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(
                                isVoiceRecording ? Color.xuanDanger : Color.xuanApricotDark
                            )

                        Text(isVoiceRecording ? "正在聆听..." : "按住说话")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 4. 情绪强度滑块
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("情绪强度")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Text("\(Int(intensity))/10")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(intensityColor)
                +
                Text("  \(intensityLabel)")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            // 滑块
            HStack(spacing: XuanSpacing.sm) {
                Text("0")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)

                Slider(value: $intensity, in: 0...10, step: 1)
                    .tint(intensityColor)

                Text("10")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            // 强度可视化条
            ComponentStyles.IntensityBar(
                value: intensity / 10.0,
                color: intensityColor
            )
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 5. 继续按钮
    private var continueButton: some View {
        Button(action: {
            // 记录情绪并导航
            // TODO: 提交情绪记录到后端
            coordinator.navigate(to: .emotionDecoder)
        }) {
            HStack(spacing: XuanSpacing.sm) {
                if let selectedId = selectedEmotion {
                    Text(emotions[selectedId].emoji)
                        .font(.system(size: 18))
                }
                Text("继续")
                    .font(XuanFont.bodyLBold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                canProceed ? Color.xuanApricot : Color.xuanApricotDisabled
            )
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
        .disabled(!canProceed)
        .animation(.easeInOut(duration: 0.2), value: canProceed)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCEmotionRecordView()
    }
}
