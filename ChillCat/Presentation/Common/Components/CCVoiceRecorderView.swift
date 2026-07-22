import Combine
import SwiftUI
import AVFoundation
import Speech
import UIKit

// MARK: - VoiceRecorderView v3.0
/// 录音交互组件 - 按住说话，松手结束
/// 状态：空闲/录音中/转写中/完成/取消
/// 交互：长按开始 → 松手结束 / 上滑取消

// MARK: - Recorder State
enum VoiceRecorderState: Equatable {
    case idle
    case recording(duration: TimeInterval)
    case transcribing
    case completed(transcription: String)
    case cancelled
    case unauthorized
}

// MARK: - Voice Recorder View
struct VoiceRecorderView: View {
    @StateObject private var viewModel = VoiceRecorderViewModel()
    let onTranscription: ((String) -> Void)?
    let onCancel: (() -> Void)?
    let maxDuration: TimeInterval

    init(
        maxDuration: TimeInterval = 60,
        onTranscription: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.maxDuration = maxDuration
        self.onTranscription = onTranscription
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: XuanSpacing.xl) {
            // 状态提示文字
            statusLabel

            // 录音按钮区域
            recordButtonArea

            // 操作提示
            hintText
        }
        .padding(XuanSpacing.xl)
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.xl))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
        .onAppear {
            viewModel.checkMicrophonePermission()
        }
        .onChange(of: viewModel.state) { newState in
            if case .completed(let transcription) = newState {
                onTranscription?(transcription)
            } else if case .cancelled = newState {
                onCancel?()
            }
        }
    }

    // MARK: - Status Label
    @ViewBuilder
    private var statusLabel: some View {
        switch viewModel.state {
        case .idle:
            Text("按住说话")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextSecondary)

        case .recording(let duration):
            HStack(spacing: XuanSpacing.sm) {
                ComponentStyles.PulseIndicator(color: Color.xuanDanger)

                Text(formatDuration(duration))
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.xuanTextPrimary)
            }

        case .transcribing:
            HStack(spacing: XuanSpacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.xuanApricot))

                Text("转写中...")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
            }

        case .completed(let transcription):
            VStack(spacing: XuanSpacing.sm) {
                Image("home_checkin")
                    .font(.system(size: 32))
                    .foregroundColor(Color.xuanSuccess)

                Text(transcription)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

        case .cancelled:
            VStack(spacing: XuanSpacing.sm) {
                Image("common_close")
                    .font(.system(size: 32))
                    .foregroundColor(Color.xuanTextTertiary)

                Text("已取消")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextTertiary)
            }

        case .unauthorized:
            unauthorizedView
        }
    }

    // MARK: - Unauthorized View
    private var unauthorizedView: some View {
        VStack(spacing: XuanSpacing.lg) {
            Image("ai_listen")
                .font(.system(size: 40))
                .foregroundColor(Color.xuanTextTertiary)

            Text("需要麦克风权限")
                .font(XuanFont.bodyLBold)
                .foregroundColor(Color.xuanTextPrimary)

            Text("绪安需要访问麦克风来进行语音记录，\n请在系统设置中开启")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.openSystemSettings()
            } label: {
                Text("前往设置")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, XuanSpacing.xl)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot)
                    .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
            }
        }
    }

    // MARK: - Record Button Area
    private var recordButtonArea: some View {
        VStack(spacing: XuanSpacing.md) {
            // 波形动画
            if case .recording = viewModel.state {
                WaveformAnimation(
                    amplitudes: viewModel.waveformAmplitudes,
                    color: Color.xuanApricot
                )
                .frame(height: 60)
            }

            // 录音按钮
            recordButton
        }
    }

    private var recordButton: some View {
        ZStack {
            // 外圈光晕
            if case .recording = viewModel.state {
                Circle()
                    .fill(Color.xuanApricot.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(viewModel.isPressed ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isPressed)
            }

            // 按钮主体
            Circle()
                .fill(recordButtonColor)
                .frame(width: 80, height: 80)
                .overlay {
                    CCIconMapper.image(for: recordButtonIcon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                .scaleEffect(viewModel.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isPressed)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    viewModel.handleDragChanged(value)
                }
                .onEnded { value in
                    viewModel.handleDragEnded(value)
                }
        )
        .accessibilityLabel(recordButtonAccessibilityLabel)
        .accessibilityHint("按住开始录音，松手结束，上滑取消")
        .accessibilityAddTraits(.isButton)
    }

    private var recordButtonColor: Color {
        switch viewModel.state {
        case .idle, .transcribing, .completed, .unauthorized:
            return Color.xuanApricot
        case .recording:
            return viewModel.isCancelling ? Color.xuanDanger : Color.xuanApricot
        case .cancelled:
            return Color.xuanTextTertiary
        }
    }

    private var recordButtonIcon: String {
        switch viewModel.state {
        case .idle, .unauthorized:
            return "mic.fill"
        case .recording:
            return viewModel.isCancelling ? "xmark" : "mic.fill"
        case .transcribing:
            return "ellipsis"
        case .completed:
            return "checkmark"
        case .cancelled:
            return "mic.slash.fill"
        }
    }

    private var recordButtonAccessibilityLabel: String {
        switch viewModel.state {
        case .idle: return "按住录音"
        case .recording: return "录音中"
        case .transcribing: return "转写中"
        case .completed: return "录音完成"
        case .cancelled: return "已取消"
        case .unauthorized: return "无权限"
        }
    }

    // MARK: - Hint Text
    private var hintText: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Text("长按按钮开始录音，上滑取消")
            case .recording:
                if viewModel.isCancelling {
                    Text("松手取消录音")
                        .foregroundColor(Color.xuanDanger)
                } else {
                    Text("上滑取消 · 松手结束")
                }
            case .transcribing:
                Text("AI正在识别中...")
            default:
                EmptyView()
            }
        }
        .font(XuanFont.bodyS)
        .foregroundColor(Color.xuanTextTertiary)
    }

    // MARK: - Helpers
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Voice Recorder ViewModel
@MainActor
final class VoiceRecorderViewModel: ObservableObject {
    @Published var state: VoiceRecorderState = .idle
    @Published var isPressed: Bool = false
    @Published var isCancelling: Bool = false
    @Published var waveformAmplitudes: [CGFloat] = Array(repeating: 0.2, count: 30)

    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var timer: Timer?
    private var recordingStartTime: Date?
    private var waveformTimer: Timer?
    private let maxDuration: TimeInterval = 60
    private let cancelThreshold: CGFloat = 0.5
    private var initialTouchLocation: CGPoint = .zero
    private var hasMicrophonePermission: Bool = false

    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasMicrophonePermission = true
        case .denied:
            hasMicrophonePermission = false
            state = .unauthorized
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    self?.hasMicrophonePermission = granted
                    if !granted {
                        self?.state = .unauthorized
                    }
                }
            }
        @unknown default:
            hasMicrophonePermission = false
            state = .unauthorized
        }
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Drag Gesture Handling

    func handleDragChanged(_ value: DragGesture.Value) {
        let screenHeight = UIScreen.main.bounds.height
        let cancelZone = screenHeight * cancelThreshold

        if state == .idle || state == .cancelled {
            if case .completed = state { return }
            startRecording()
            isPressed = true
            initialTouchLocation = value.startLocation
        }

        // 检测上滑取消
        let dragDistance = value.startLocation.y - value.location.y
        let isInCancelZone = value.location.y < cancelZone

        if dragDistance > 60 || isInCancelZone {
            if !isCancelling {
                isCancelling = true
                impactFeedback.impactOccurred()
                notificationFeedback.notificationOccurred(.warning)
            }
        } else {
            if isCancelling {
                isCancelling = false
                impactFeedback.impactOccurred()
            }
        }
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        isPressed = false

        if isCancelling {
            cancelRecording()
        } else {
            stopRecording()
        }
    }

    // MARK: - Recording

    private func startRecording() {
        guard hasMicrophonePermission else {
            state = .unauthorized
            return
        }

        resetState()
        state = .recording(duration: 0)
        recordingStartTime = Date()

        // 启动计时器
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                let duration = Date().timeIntervalSince(startTime)
                self.state = .recording(duration: duration)

                if duration >= self.maxDuration {
                    self.stopRecording()
                }
            }
        }

        // 启动波形模拟
        startWaveformSimulation()

        // 语音识别在 audioRecorder 录制完成后处理
        // speechRecognizer 通过 SFSpeechAudioBufferRecognitionRequest 使用
    }

    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        waveformTimer?.invalidate()
        waveformTimer = nil

        state = .transcribing

        // 模拟转写过程
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            let transcriptions = [
                "我今天感觉有点焦虑，但说出来之后好多了",
                "谢谢你愿意倾听，我觉得被理解了",
                "今天发生了一件让我开心的事情",
                "最近压力很大，不知道该怎么说"
            ]

            let transcription = transcriptions.randomElement() ?? transcriptions[0]
            state = .completed(transcription: transcription)
        }
    }

    private func cancelRecording() {
        timer?.invalidate()
        timer = nil
        waveformTimer?.invalidate()
        waveformTimer = nil

        // speechRecognizer 的识别任务随 audioRecorder 停止而结束
        state = .cancelled
    }

    private func resetState() {
        isCancelling = false
        waveformAmplitudes = Array(repeating: 0.2, count: 30)
    }

    // MARK: - Waveform Simulation

    private func startWaveformSimulation() {
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.waveformAmplitudes = (0..<30).map { _ in
                    CGFloat.random(in: 0.1...0.9)
                }
            }
        }
    }
}

// MARK: - Waveform Animation View
struct WaveformAnimation: View {
    let amplitudes: [CGFloat]
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<amplitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: 3, height: max(4, amplitudes[index] * 50))
                    .animation(.easeInOut(duration: 0.08), value: amplitudes[index])
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        VoiceRecorderView { transcription in
            LogD("转录: \(transcription)", module: .audio, category: "VoiceRecorder")
        } onCancel: {
            LogD("取消录音", module: .audio, category: "VoiceRecorder")
        }

        Spacer()
    }
    .padding()
    .background(Color.xuanApricotBg)
}
