//
//  CCVoiceDiaryViewModel.swift
//  绪安 - 语音情绪日记 ViewModel
//

import Foundation
import SwiftUI
import Observation
import Combine

// MARK: - Voice Diary State

enum CCVoiceDiaryState: Equatable {
    case idle
    case recording
    case analyzing
    case result(CCVoiceDiaryResult)
    case saving
    case saved
    case error(String)
}

// MARK: - Voice Diary Result

struct CCVoiceDiaryResult: Equatable {
    var emotion: String
    var confidence: Double
    var transcription: String
    var tags: [String]

    init(emotion: String, confidence: Double, transcription: String, tags: [String]) {
        self.emotion = emotion
        self.confidence = confidence
        self.transcription = transcription
        self.tags = tags
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCVoiceDiaryViewModel {

    // MARK: - Published State

    var state: CCVoiceDiaryState = .idle
    var recordingDuration: Int = 0
    var waveformData: [CGFloat] = Array(repeating: 4, count: 30)
    var editableTranscription: String = ""
    var editableTags: [String] = []
    var newTagInput: String = ""

    // MARK: - Private

    private var timer: Timer?
    private let waveformBarCount = 30
    private var lastDiaryResult: CCVoiceDiaryResult?

    // MARK: - Computed Helpers

    var isRecording: Bool {
        if case .recording = state { return true }
        return false
    }

    var isAnalyzing: Bool {
        if case .analyzing = state { return true }
        return false
    }

    var hasResult: Bool {
        if case .result = state { return true }
        return false
    }

    var isSaving: Bool {
        if case .saving = state { return true }
        return false
    }

    var isSaved: Bool {
        if case .saved = state { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let msg) = state { return msg }
        return nil
    }

    var resultData: CCVoiceDiaryResult? {
        if case .result(let data) = state { return data }
        if case .saved = state { return lastDiaryResult }
        if case .error = state { return lastDiaryResult }
        return nil
    }

    var formattedDuration: String {
        String(format: "%02d:%02d", recordingDuration / 60, recordingDuration % 60)
    }

    var confidencePercent: String {
        guard let result = resultData else { return "" }
        return String(format: "%.0f%%", result.confidence * 100)
    }

    var confidenceColor: Color {
        guard let result = resultData else { return Color.xuanApricotDark }
        if result.confidence >= 0.7 { return Color.xuanMint }
        if result.confidence >= 0.4 { return Color.xuanApricotDark }
        return Color.xuanDanger
    }

    // MARK: - Recording

    func startRecording() {
        CCHaptic.medium()
        state = .recording
        recordingDuration = 0
        startTimer()
    }

    func stopRecording() {
        CCHaptic.medium()
        state = .analyzing
        stopTimer()
        Task {
            do {
                // 模拟 AI 分析延迟 (1-2s)
                try await Task.sleep(nanoseconds: 1_500_000_000)
                await performAnalysis()
            } catch {
                state = .error("录音处理中断，请重试")
            }
        }
    }

    // MARK: - AI Analysis

    private func performAnalysis() async {
        // Phase 1: 没有真实语音识别，使用录音时长生成模拟转录
        // 后续 Phase 2 接入真正的语音识别 API
        let simulatedTranscription = generateSimulatedTranscription()

        do {
            // 调用 AI 文本分析接口分析情绪
            let analysis = try await CCXuanAPI.analyze(text: simulatedTranscription)

            let result = CCVoiceDiaryResult(
                emotion: analysis.emotion,
                confidence: analysis.confidence,
                transcription: simulatedTranscription,
                tags: analysis.tags
            )
            editableTranscription = result.transcription
            editableTags = result.tags
            state = .result(result)
        } catch {
            // API 失败时降级为本地情绪推断
            let result = CCVoiceDiaryResult(
                emotion: inferEmotion(from: simulatedTranscription),
                confidence: 0.6,
                transcription: simulatedTranscription,
                tags: inferTags(from: simulatedTranscription)
            )
            editableTranscription = result.transcription
            editableTags = result.tags
            state = .result(result)
        }
    }

    /// 根据录音时长生成模拟转录文案
    private func generateSimulatedTranscription() -> String {
        // Phase 1: 录音时长 > 0 时提示用户编辑
        if recordingDuration > 0 {
            return "录音 \(formattedDuration)，请点击编辑写下你的感受..."
        }
        return "点击编辑写下你的感受..."
    }

    /// 本地情绪推断（API 不可用时降级）
    private func inferEmotion(from text: String) -> String {
        if text.contains("焦虑") || text.contains("紧张") || text.contains("压力") { return "焦虑" }
        if text.contains("开心") || text.contains("高兴") || text.contains("好") { return "开心" }
        if text.contains("孤独") || text.contains("一个人") { return "孤独" }
        if text.contains("委屈") || text.contains("不公平") { return "委屈" }
        return "平静"
    }

    /// 本地标签推断
    private func inferTags(from text: String) -> [String] {
        var tags: [String] = []
        if text.contains("工作") || text.contains("老板") || text.contains("开会") { tags.append("#职场") }
        if text.contains("家") || text.contains("妈") || text.contains("爸") { tags.append("#家庭") }
        if text.contains("朋友") { tags.append("#社交") }
        if tags.isEmpty { tags = ["#日常"] }
        return tags
    }

    // MARK: - Save

    func saveDiary() async {
        guard let result = resultData else { return }
        lastDiaryResult = result
        CCHaptic.success()
        state = .saving
        do {
            // Phase 1: 使用 emotion checkin 替代语音保存
            try await CCXuanAPI.checkin(
                emotion: result.emotion,
                note: editableTranscription
            )
            state = .saved
        } catch {
            state = .error("保存失败，请重试")
        }
    }

    // MARK: - Reset / Re-record

    func resetToIdle() {
        stopTimer()
        state = .idle
        recordingDuration = 0
        waveformData = Array(repeating: 4, count: waveformBarCount)
        editableTranscription = ""
        editableTags = []
        newTagInput = ""
        lastDiaryResult = nil
    }

    func reRecord() {
        resetToIdle()
    }

    // MARK: - Tag Management

    func addTag() {
        let trimmed = newTagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let formatted = trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
        if !editableTags.contains(formatted) {
            editableTags.append(formatted)
        }
        newTagInput = ""
    }

    func removeTag(_ tag: String) {
        editableTags.removeAll { $0 == tag }
    }

    // MARK: - Private Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.recordingDuration += 1
                self.generateWaveform()
            }
        }
        // Fire immediately for initial waveform
        generateWaveform()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        waveformData = Array(repeating: 4, count: waveformBarCount)
    }

    private func generateWaveform() {
        // 模拟实时音量波形: 中心高、两侧低
        let center = waveformBarCount / 2
        waveformData = (0..<waveformBarCount).map { i in
            let distanceFromCenter = abs(i - center)
            let baseAmplitude: CGFloat = max(8, 60 - CGFloat(distanceFromCenter) * 2.5)
            let variation = CGFloat.random(in: -12...12)
            return max(4, min(60, baseAmplitude + variation))
        }
    }
}
