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
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    Spacer().frame(height: AppSpacing.sm)

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
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
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
        VStack(spacing: AppSpacing.xl) {
            Spacer().frame(height: 40)

            Text("随便说什么都好，这里不评判…")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            idleWaveform
                .frame(height: 80)

            Spacer().frame(height: AppSpacing.sm)

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
                .foregroundColor(AppTheme.textMuted)

            Spacer()
        }
    }

    // MARK: - Recording State

    private var recordingStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: 20)

            Text("正在聆听…")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textSecondary)

            liveWaveform
                .frame(height: 80)
                .padding(.vertical, AppSpacing.md)

            Text(viewModel.formattedDuration)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppTheme.primary)
                .monospacedDigit()

            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.crisisRed)
                    .frame(width: 8, height: 8)
                    .opacity(viewModel.recordingDuration % 2 == 0 ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.recordingDuration)

                Text("录制中")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.crisisRed)
            }

            Spacer().frame(height: AppSpacing.md)

            ZStack {
                Circle()
                    .stroke(AppTheme.primaryMuted, lineWidth: 3)
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(AppTheme.crisisRed)
                    .frame(width: 70, height: 70)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)

            Text("松手完成录音")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textMuted)

            Spacer()
        }
    }

    // MARK: - Analyzing State

    private var analyzingStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: 60)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(AppTheme.primaryMuted)
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
                .foregroundColor(AppTheme.textSecondary)

            Text("这可能需要 1-2 秒")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)

            Spacer()
        }
    }

    // MARK: - Result State

    private var resultStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            analysisResultCard
            transcriptionEditor
            tagsEditor
            actionButtons
        }
    }

    private var analysisResultCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "heart.text.clinic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.accentMint)
                Text("情绪识别:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                Text(viewModel.resultData?.emotion ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                Spacer()
                Text(viewModel.confidencePercent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(viewModel.confidenceColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.confidenceColor.opacity(0.12))
                    .cornerRadius(AppRadius.sm)
            }

            if viewModel.resultData != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.primaryMuted.opacity(0.3))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.confidenceColor)
                            .frame(width: geo.size.width * CGFloat(viewModel.resultData?.confidence ?? 0), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Divider().background(AppTheme.primaryMuted.opacity(0.3))

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primaryLight)
                    .frame(width: 20)
                Text("转文字:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text(viewModel.resultData?.transcription ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
            }

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.warmLight)
                    .frame(width: 20)
                Text("标签:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text(viewModel.resultData?.tags.map { $0 }.joined(separator: " ") ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.warm)
            }
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Transcription Editor

    private var transcriptionEditor: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("编辑转文字")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Button(action: { showEmojiPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 16))
                        Text("表情")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.primaryMuted.opacity(0.2))
                    .cornerRadius(AppRadius.sm)
                }
            }

            TextEditor(text: $viewModel.editableTranscription)
                .font(.system(size: 15))
                .focused($transcriptionFocused)
                .padding(AppSpacing.sm)
                .frame(minHeight: 80)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(transcriptionFocused ? AppTheme.primary.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - Tags Editor

    private var tagsEditor: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("情绪标签")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.editableTags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.warm)
                        Button(action: { viewModel.removeTag(tag) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.warmLight.opacity(0.12))
                    .cornerRadius(AppRadius.sm)
                }
            }

            HStack(spacing: AppSpacing.sm) {
                TextField("添加标签…", text: $viewModel.newTagInput)
                    .font(.system(size: 14))
                    .focused($tagFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)

                Button(action: {
                    viewModel.addTag()
                    tagFocused = false
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(
                            viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppTheme.textMuted : AppTheme.primary
                        )
                }
                .disabled(viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
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
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.md)
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
                .background(AppTheme.primary)
                .cornerRadius(AppRadius.md)
            }
        }
    }

    // MARK: - Saving State

    private var savingStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: 80)
            ProgressView()
                .scaleEffect(1.5)
            Text("正在保存日记…")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
    }

    // MARK: - Saved State

    private var savedStateView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                Spacer().frame(height: 40)

                // 打卡成功图标
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.accentMint)

                Text("打卡成功")
                    .font(AppFont.title2)
                    .foregroundColor(AppTheme.textPrimary)

                if let result = viewModel.resultData {
                    VStack(spacing: 2) {
                        Text("情绪: \(result.emotion)")
                            .font(AppFont.body)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("时长: \(viewModel.formattedDuration)")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }

                // AI 回应卡片
                aiResponseCard

                // 3 个操作按钮
                actionButtons

                Spacer(minLength: 20)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppTheme.background)
    }

    // MARK: - AI 回应卡片
    private var aiResponseCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentMint.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.accentMint)
                }

                Text("AI 倾听官")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Text("刚刚")
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textMuted)
            }

            Text("我听到了你的声音，感受到了你的情绪。\n你愿意和我再多聊一会儿吗？")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textPrimary)
                .lineSpacing(6)

            HStack(spacing: AppSpacing.sm) {
                Text("💚 温暖陪伴")
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.accentMint)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 2)
                    .background(AppTheme.accentMint.opacity(0.1))
                    .cornerRadius(AppRadius.full)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color(hex: "2C2416").opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: { coordinator.navigate(to: .aiListener) }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "brain.head.profile")
                    Text("继续和AI聊聊")
                }
                .font(AppFont.buttonLabel)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppRadius.lg)
            }

            Button(action: { coordinator.navigate(to: .resonanceWall) }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "heart.fill")
                    Text("匿名发布到共鸣墙")
                }
                .font(AppFont.buttonLabel)
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primary.opacity(0.08))
                .cornerRadius(AppRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                )
            }

            Button(action: { coordinator.navigate(to: .emotionDecoder) }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "chart.bar.fill")
                    Text("查看情绪解码")
                }
                .font(AppFont.buttonLabel)
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.lg)
            }
        }
    }

    // MARK: - Error State

    private var errorStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: 60)

            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(AppTheme.error)

            Text(viewModel.errorMessage ?? "发生未知错误")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: AppSpacing.md) {
                Button(action: { viewModel.reRecord() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15))
                        Text("重新录制")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                }

                Button(action: {
                    Task { await viewModel.saveDiary() }
                }) {
                    Text("重试保存")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primary)
                        .cornerRadius(AppRadius.md)
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
                    .fill(AppTheme.primaryMuted.opacity(0.4))
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
                            ? AppTheme.primary.opacity(0.5 + Double(viewModel.waveformData[i]) / 120)
                            : AppTheme.primaryMuted
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
                .stroke(AppTheme.primaryMuted, lineWidth: 3)
                .frame(width: 100, height: 100)

            Circle()
                .fill(isPressed ? AppTheme.crisisRed : AppTheme.primary)
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

