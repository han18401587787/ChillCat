//
//  CCVoiceDiaryViewModel.swift
//  绪安 - 语音情绪日记 ViewModel
//

import Foundation
import SwiftUI
import Observation

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
        guard let result = resultData else { return AppTheme.primaryDark }
        if result.confidence >= 0.7 { return AppTheme.accentMint }
        if result.confidence >= 0.4 { return AppTheme.warmGold }
        return AppTheme.crisisRed
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
        do {
            // 调用语音分析 API — Phase 1 模拟，不传音频数据
            let analysis = try await CCXuanAPI.analyze(text: "语音日记模拟分析")

            let result = CCVoiceDiaryResult(
                emotion: analysis.emotion,
                confidence: analysis.confidence,
                transcription: "今天开会又被老板批评了，感觉很委屈，明明不是我的问题...",
                tags: analysis.tags
            )
            editableTranscription = result.transcription
            editableTags = result.tags
            state = .result(result)
        } catch {
            // 降级为模拟数据
            let result = CCVoiceDiaryResult(
                emotion: "焦虑",
                confidence: 0.85,
                transcription: "今天开会又被老板批评了，感觉很委屈，明明不是我的问题...",
                tags: ["职场", "压力", "委屈"]
            )
            editableTranscription = result.transcription
            editableTags = result.tags
            state = .result(result)
        }
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
