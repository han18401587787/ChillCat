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
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var transcriptionFocused: Bool
    @FocusState private var tagFocused: Bool

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: theme.spacingLG) {
                    Spacer().frame(height: theme.spacingSM)

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
                .padding(.horizontal, theme.spacingMD)
                .padding(.bottom, theme.spacingXL)
            }
            .scrollDisabled(viewModel.state == .idle || viewModel.isRecording)

            // Emoji Picker overlay
            if showEmojiPicker {
                VStack {
                    Spacer()
                    CCEmojiPicker(isShowing: $showEmojiPicker) { emoji in
                        viewModel.editableTranscription += emoji
                    }
                    .frame(height: 300)
                    .background(theme.background)
                    .cornerRadius(theme.radiusXL)
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
        .animation(.easeInOut, value: showEmojiPicker)
        .navigationTitle("语音打卡")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Idle State

    private var idleStateView: some View {
        VStack(spacing: theme.spacingXL) {
            Spacer().frame(height: 40)

            Text("随便说什么都好，这里不评判…")
                .font(.system(size: 18))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)

            idleWaveform
                .frame(height: 80)

            Spacer().frame(height: theme.spacingSM)

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
                .foregroundColor(theme.textMuted)

            Spacer()
        }
    }

    // MARK: - Recording State

    private var recordingStateView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer().frame(height: 20)

            Text("正在聆听…")
                .font(.system(size: 18))
                .foregroundColor(theme.textSecondary)

            liveWaveform
                .frame(height: 80)
                .padding(.vertical, theme.spacingMD)

            Text(viewModel.formattedDuration)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(theme.primary)
                .monospacedDigit()

            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "E57373"))
                    .frame(width: 8, height: 8)
                    .opacity(viewModel.recordingDuration % 2 == 0 ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.recordingDuration)

                Text("录制中")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "E57373"))
            }

            Spacer().frame(height: theme.spacingMD)

            ZStack {
                Circle()
                    .stroke(theme.primaryMuted, lineWidth: 3)
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(Color(hex: "E57373"))
                    .frame(width: 70, height: 70)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)

            Text("松手完成录音")
                .font(.system(size: 14))
                .foregroundColor(theme.textMuted)

            Spacer()
        }
    }

    // MARK: - Analyzing State

    private var analyzingStateView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer().frame(height: 60)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(theme.primaryMuted)
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
                .foregroundColor(theme.textSecondary)

            Text("这可能需要 1-2 秒")
                .font(.system(size: 13))
                .foregroundColor(theme.textMuted)

            Spacer()
        }
    }

    // MARK: - Result State

    private var resultStateView: some View {
        VStack(spacing: theme.spacingLG) {
            analysisResultCard
            transcriptionEditor
            tagsEditor
            actionButtons
        }
    }

    private var analysisResultCard: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            HStack(spacing: theme.spacingSM) {
                Image(systemName: "heart.text.clinic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "66BB6A"))
                Text("情绪识别:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                Text(viewModel.resultData?.emotion ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.primary)
                Spacer()
                Text(viewModel.confidencePercent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(viewModel.confidenceColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.confidenceColor.opacity(0.12))
                    .cornerRadius(theme.radiusSM)
            }

            if viewModel.resultData != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.primaryMuted.opacity(0.3))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.confidenceColor)
                            .frame(width: geo.size.width * CGFloat(viewModel.resultData?.confidence ?? 0), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Divider().background(theme.primaryMuted.opacity(0.3))

            HStack(alignment: .top, spacing: theme.spacingSM) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.primaryLight)
                    .frame(width: 20)
                Text("转文字:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Text(viewModel.resultData?.transcription ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(theme.textPrimary)
                    .lineSpacing(4)
            }

            HStack(alignment: .top, spacing: theme.spacingSM) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.warmLight)
                    .frame(width: 20)
                Text("标签:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Text(viewModel.resultData?.tags.map { $0 }.joined(separator: " ") ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(theme.warm)
            }
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Transcription Editor

    private var transcriptionEditor: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            HStack {
                Text("编辑转文字")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Spacer()
                Button(action: { showEmojiPicker.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 16))
                        Text("表情")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.primaryMuted.opacity(0.2))
                    .cornerRadius(theme.radiusSM)
                }
            }

            TextEditor(text: $viewModel.editableTranscription)
                .font(.system(size: 15))
                .focused($transcriptionFocused)
                .padding(theme.spacingSM)
                .frame(minHeight: 80)
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radiusMD)
                        .stroke(transcriptionFocused ? theme.primary.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - Tags Editor

    private var tagsEditor: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            Text("情绪标签")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.textSecondary)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.editableTags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.system(size: 13))
                            .foregroundColor(theme.warm)
                        Button(action: { viewModel.removeTag(tag) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textMuted)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.warmLight.opacity(0.12))
                    .cornerRadius(theme.radiusSM)
                }
            }

            HStack(spacing: theme.spacingSM) {
                TextField("添加标签…", text: $viewModel.newTagInput)
                    .font(.system(size: 14))
                    .focused($tagFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                Button(action: {
                    viewModel.addTag()
                    tagFocused = false
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(
                            viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty
                                ? theme.textMuted : theme.primary
                        )
                }
                .disabled(viewModel.newTagInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: theme.spacingMD) {
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
                .foregroundColor(theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)
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
                .background(theme.primary)
                .cornerRadius(theme.radiusMD)
            }
        }
    }

    // MARK: - Saving State

    private var savingStateView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer().frame(height: 80)
            ProgressView()
                .scaleEffect(1.5)
            Text("正在保存日记…")
                .font(.system(size: 18))
                .foregroundColor(theme.textSecondary)
            Spacer()
        }
    }

    // MARK: - Saved State

    private var savedStateView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer().frame(height: 60)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(theme.softGreen)

            Text("打卡成功")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.textPrimary)

            if let result = viewModel.resultData {
                VStack(spacing: 4) {
                    Text("情绪: \(result.emotion)")
                        .font(.system(size: 15))
                        .foregroundColor(theme.textSecondary)
                    Text("时长: \(viewModel.formattedDuration)")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textMuted)
                }
            }

            Spacer().frame(height: theme.spacingMD)

            HStack(spacing: theme.spacingMD) {
                Button(action: { viewModel.reRecord() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 15))
                        Text("再录一条")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }

                Button(action: {
                    coordinator.pop()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 15))
                        Text("返回首页")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.primary)
                    .cornerRadius(theme.radiusMD)
                }
            }

            Spacer()
        }
    }

    // MARK: - Error State

    private var errorStateView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer().frame(height: 60)

            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(theme.error)

            Text(viewModel.errorMessage ?? "发生未知错误")
                .font(.system(size: 18))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: theme.spacingMD) {
                Button(action: { viewModel.reRecord() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15))
                        Text("重新录制")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }

                Button(action: {
                    Task { await viewModel.saveDiary() }
                }) {
                    Text("重试保存")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.primary)
                        .cornerRadius(theme.radiusMD)
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
                    .fill(theme.primaryMuted.opacity(0.4))
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
                            ? theme.primary.opacity(0.5 + Double(viewModel.waveformData[i]) / 120)
                            : theme.primaryMuted
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
                .stroke(theme.primaryMuted, lineWidth: 3)
                .frame(width: 100, height: 100)

            Circle()
                .fill(isPressed ? Color(hex: "E57373") : theme.primary)
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

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(proposal).height }.max() ?? 0 }.reduce(0, +)
            + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row {
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.sizeThatFits(.unspecified).width + spacing
            }
            y += (row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0) + spacing
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubview]] = []
        var currentRow: [LayoutSubview] = []
        var currentX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [subview]
                currentX = size.width + spacing
            } else {
                currentRow.append(subview)
                currentX += size.width + spacing
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }
}
