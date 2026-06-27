//
//  CCVoiceCheckinView.swift
//  绪安 - 语音情绪日记 (升级版)
//

import SwiftUI

struct CCVoiceCheckinView: View {
    @State private var viewModel = CCVoiceDiaryViewModel()
    @State private var showEmojiPicker = false
    @State private var isPressed = false
    @Environment(CCAppCoordinator.self) private var coordinator
    @FocusState private var transcriptionFocused: Bool
    @FocusState private var tagFocused: Bool

    var body: some View {
        ZStack {
            Color.xuanApricotBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: XuanSpacing.lg) {
                    Spacer().frame(height: XuanSpacing.sm)

                    switch viewModel.state {
                    case .idle:
                        idleStateView
                    case .recording:
                        recordingStateView
                    case .analyzing:
                        analyzingStateView
                    case .result:
                        resultStateView
                    case .saving:
                        savingStateView
                    case .saved:
                        savedStateView
                    case .error:
                        errorStateView
                    }
                }
                .padding(.horizontal, XuanSpacing.md)
                .padding(.bottom, XuanSpacing.xl)
            }
            .scrollDisabled(viewModel.state == .idle || viewModel.isRecording)
        }
        .cc_emojiPickerOverlay(isShowing: $showEmojiPicker) { emoji in
            viewModel.editableTranscription += emoji.displayName
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
        .animation(.easeInOut, value: showEmojiPicker)
        .navigationTitle("语音日记")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Idle State

    private var idleStateView: some View {
        VStack(spacing: XuanSpacing.xl) {
            Spacer().frame(height: 40)

            Text("随便说什么都好，这里不评判…")
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)

            idleWaveform
                .frame(height: 80)

            Spacer().frame(height: XuanSpacing.sm)

            recordButton
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                                viewModel.startRecording()
                            }
                        }
                        .onEnded { _ in
                            isPressed = false
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            }
                        }
                )

            Text("按住说话…")
                .font(.system(size: 14))
                .foregroundColor(Color.xuanTextTertiary)

            Spacer()
        }
    }

    // MARK: - Recording State

    private var recordingStateView: some View {
        VStack(spacing: XuanSpacing.lg) {
            Spacer().frame(height: 20)

            Text("正在聆听…")
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextSecondary)

            liveWaveform
                .frame(height: 80)
                .padding(.vertical, XuanSpacing.md)

            Text(viewModel.formattedDuration)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color.xuanApricot)
                .monospacedDigit()

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.xuanDanger)
                    .frame(width: 8, height: 8)
                    .opacity(viewModel.recordingDuration % 2 == 0 ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.recordingDuration)

                Text("录制中")
                    .font(.system(size: 13))
                    .foregroundColor(Color.xuanDanger)
            }

            Spacer().frame(height: XuanSpacing.md)

            ZStack {
                Circle()
                    .stroke(Color.xuanApricot.opacity(0.6), lineWidth: 3)
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(Color.xuanDanger)
                    .frame(width: 70, height: 70)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)

            Text("松手完成录音")
                .font(.system(size: 14))
                .foregroundColor(Color.xuanTextTertiary)

            Spacer()
        }
    }

    // MARK: - Analyzing State

    private var analyzingStateView: some View {
        VStack(spacing: XuanSpacing.lg) {
            Spacer().frame(height: 60)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.xuanApricot.opacity(0.6))
                        .frame(width: 12, height: 12)
                        .scaleEffect(viewModel.isAnalyzing ? (i == 0 ? 1.3 : i == 1 ? 1.0 : 0.7) : 0.5)
                        .animation(
                            .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.15),
                            value: viewModel.isAnalyzing
                        )
                }
            }
            .frame(height: 80)

            Text("AI 正在理解你的情绪…")
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextSecondary)

            Text("这可能需要 1-2 秒")
                .font(.system(size: 13))
                .foregroundColor(Color.xuanTextTertiary)

            Spacer()
        }
    }

    // MARK: - Result State

    private var resultStateView: some View {
        VStack(spacing: XuanSpacing.lg) {
            analysisResultCard
            transcriptionEditor
            tagsEditor
            actionButtons
        }
    }

    private var analysisResultCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Image(systemName: "heart.text.clinic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.xuanMint)
                Text("情绪识别:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.xuanTextPrimary)
                Text(viewModel.resultData?.emotion ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.xuanApricot)
                Spacer()
                Text(viewModel.confidencePercent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(viewModel.confidenceColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.confidenceColor.opacity(0.12))
                    .cornerRadius(XuanRadius.sm)
            }

            if viewModel.resultData != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.xuanApricot.opacity(0.6).opacity(0.3))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.confidenceColor)
                            .frame(width: geo.size.width * CGFloat(viewModel.resultData?.confidence ?? 0), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Divider().background(Color.xuanApricot.opacity(0.6).opacity(0.3))

            HStack(alignment: .top, spacing: XuanSpacing.sm) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanApricotLight)
                    .frame(width: 20)
                Text("转文字:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                Text(viewModel.resultData?.transcription ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextPrimary)
                    .lineSpacing(4)
            }

            HStack(alignment: .top, spacing: XuanSpacing.sm) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanApricotLight)
                    .frame(width: 20)
                Text("标签:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                Text(viewModel.resultData?.tags.map { $0 }.joined(separator: " ") ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanApricotDark)
            }
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Transcription Editor

    private var transcriptionEditor: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            HStack {
                Text("编辑转文字")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                Spacer()
                Button(action: { showEmojiPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 16))
                        Text("表情")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color.xuanApricot)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.xuanApricot.opacity(0.6).opacity(0.2))
                    .cornerRadius(XuanRadius.sm)
                }
            }

            TextEditor(text: $viewModel.editableTranscription)
                .font(.system(size: 15))
                .focused($transcriptionFocused)
                .padding(XuanSpacing.sm)
                .frame(minHeight: 80)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: XuanRadius.md)
                        .stroke(transcriptionFocused ? Color.xuanApricot.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - Tags Editor

    private var tagsEditor: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            Text("情绪标签")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.xuanTextSecondary)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.editableTags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.system(size: 13))
                            .foregroundColor(Color.xuanApricotDark)
                        Button(action: { viewModel.removeTag(tag) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.xuanTextTertiary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.xuanApricotLight.opacity(0.12))
                    .cornerRadius(XuanRadius.sm)
                }
            }

            HStack(spacing: XuanSpacing.sm) {
                TextField("添加标签…", text: $viewModel.newTagInput)
                    .font(.system(size: 14))
                    .focused($tagFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)

                Button(action: {
                    viewModel.addTag()
                    tagFocused = false
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(
                            viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.xuanTextTertiary : Color.xuanApricot
                        )
                }
                .disabled(viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: XuanSpacing.md) {
            Button(action: {
                CCHaptic.selection()
                viewModel.reRecord()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15))
                    Text("重新录制")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(Color.xuanTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)
            }

            Button(action: {
                Task { await viewModel.saveDiary() }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 15))
                    Text("保存日记")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanApricot)
                .cornerRadius(XuanRadius.md)
            }
        }
    }

    // MARK: - Saving State

    private var savingStateView: some View {
        VStack(spacing: XuanSpacing.lg) {
            Spacer().frame(height: 80)
            ProgressView()
                .scaleEffect(1.5)
            Text("正在保存日记…")
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextSecondary)
            Spacer()
        }
    }

    // MARK: - Saved State

    private var savedStateView: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.lg) {
                Spacer().frame(height: 40)

                // 打卡成功图标
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.xuanMint)

                Text("打卡成功")
                    .font(XuanFont.h2)
                    .foregroundColor(Color.xuanTextPrimary)

                if let result = viewModel.resultData {
                    VStack(spacing: 2) {
                        Text("情绪: \(result.emotion)")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanTextSecondary)
                        Text("时长: \(viewModel.formattedDuration)")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                }

                // AI 回应卡片
                aiResponseCard

                // 3 个操作按钮
                savedActionButtons

                Spacer(minLength: 20)
            }
            .padding(.horizontal, XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
    }

    // MARK: - AI 回应卡片
    private var aiResponseCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.xuanMint.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(Color.xuanMint)
                }

                Text("AI 倾听官")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Text("刚刚")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text("我听到了你的声音，感受到了你的情绪。\n你愿意和我再多聊一会儿吗？")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(6)

            HStack(spacing: XuanSpacing.sm) {
                Text("💚 温暖陪伴")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanMint)
                    .padding(.horizontal, XuanSpacing.sm)
                    .padding(.vertical, 2)
                    .background(Color.xuanMint.opacity(0.1))
                    .cornerRadius(XuanRadius.full)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 操作按钮（已保存状态）
    private var savedActionButtons: some View {
        VStack(spacing: XuanSpacing.sm) {
            Button(action: { coordinator.navigate(to: .aiListener) }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "brain.head.profile")
                    Text("继续和AI聊聊")
                }
                .font(XuanFont.bodyLMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanApricot)
                .cornerRadius(XuanRadius.lg)
            }

            Button(action: { coordinator.navigate(to: .resonanceWall) }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "heart.fill")
                    Text("匿名发布到共鸣墙")
                }
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanApricot)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "F2DBC9"))
                .cornerRadius(XuanRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: XuanRadius.lg)
                        .stroke(Color(hex: "F2DBC9"), lineWidth: 1)
                )
            }

            Button(action: { coordinator.navigate(to: .emotionDecoder) }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "chart.bar.fill")
                    Text("查看情绪解码")
                }
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.lg)
            }
        }
    }

    // MARK: - Error State

    private var errorStateView: some View {
        VStack(spacing: XuanSpacing.lg) {
            Spacer().frame(height: 60)

            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Color.xuanDanger)

            Text(viewModel.errorMessage ?? "发生未知错误")
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: XuanSpacing.md) {
                Button(action: { viewModel.reRecord() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15))
                        Text("重新录制")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }

                Button(action: {
                    Task { await viewModel.saveDiary() }
                }) {
                    Text("重试保存")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .disabled(viewModel.resultData == nil)
            }

            Spacer()
        }
    }

    // MARK: - Waveform Views

    private var idleWaveform: some View {
        HStack(spacing: 2) {
            ForEach(0..<30, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.xuanApricot.opacity(0.6).opacity(0.4))
                    .frame(width: 3, height: 6)
            }
        }
    }

    private var liveWaveform: some View {
        HStack(spacing: 2) {
            ForEach(0..<viewModel.waveformData.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        viewModel.isRecording
                            ? Color.xuanApricot.opacity(0.5 + Double(viewModel.waveformData[i]) / 120)
                            : Color.xuanApricot.opacity(0.6)
                    )
                    .frame(width: 3, height: max(4, viewModel.waveformData[i]))
                    .animation(.easeInOut(duration: 0.15), value: viewModel.waveformData[i])
            }
        }
    }

    // MARK: - Record Button

    private var recordButton: some View {
        ZStack {
            Circle()
                .stroke(Color.xuanApricot.opacity(0.6), lineWidth: 3)
                .frame(width: 100, height: 100)

            Circle()
                .fill(isPressed ? Color.xuanDanger : Color.xuanApricot)
                .frame(width: isPressed ? 70 : 80, height: isPressed ? 70 : 80)
                .animation(.easeInOut(duration: 0.15), value: isPressed)

            Image(systemName: "mic.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

