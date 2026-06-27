//
//  CCBodyScanViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 正念身体扫描 ViewModel
//

import Foundation
import SwiftUI
import Combine

// MARK: - Body Region Model

struct CCBodyRegion: Identifiable {
    let id: String
    let name: String
    let question: String
    let position: CGPoint  // Normalized 0-1 position on body outline
    let color: Color

    static let all: [CCBodyRegion] = [
        .init(id: "head_top", name: "头顶", question: "注意你的头顶，有什么感觉？", position: CGPoint(x: 0.5, y: 0.05), color: AppTheme.info),
        .init(id: "face", name: "面部", question: "注意你的面部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.14), color: AppTheme.calmBlue),
        .init(id: "neck", name: "颈部", question: "注意你的颈部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.21), color: AppTheme.accentMint),
        .init(id: "shoulders", name: "肩膀", question: "注意你的肩膀，有什么感觉？", position: CGPoint(x: 0.5, y: 0.26), color: AppTheme.warmPurple),
        .init(id: "chest", name: "胸部", question: "注意你的胸部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.34), color: AppTheme.warning),
        .init(id: "abdomen", name: "腹部", question: "注意你的腹部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.42), color: AppTheme.warmPink),
        .init(id: "back", name: "背部", question: "注意你的背部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.36), color: AppTheme.accentMint),
        .init(id: "hands", name: "双手", question: "注意你的双手，有什么感觉？", position: CGPoint(x: 0.5, y: 0.55), color: AppTheme.calmBlue),
        .init(id: "legs", name: "双腿", question: "注意你的双腿，有什么感觉？", position: CGPoint(x: 0.5, y: 0.72), color: AppTheme.warmPurple),
        .init(id: "feet", name: "脚部", question: "注意你的脚部，有什么感觉？", position: CGPoint(x: 0.5, y: 0.93), color: AppTheme.info),
    ]
}

// MARK: - Body Scan Phase

enum CCBodyScanPhase: Equatable {
    case idle
    case scanning(regionIndex: Int)
    case completed
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCBodyScanViewModel {
    var phase: CCBodyScanPhase = .idle
    var currentRegionIndex: Int = 0
    var secondsInRegion: Int = 0
    var totalElapsedSeconds: Int = 0
    var isPaused: Bool = false
    var regionDuration: Int = 30  // configurable

    // Notes
    var sensationNotes: [String: String] = [:]  // regionId -> note

    // Audio guidance
    var audioGuidanceEnabled: Bool = false

    // Timer
    private var timer: Timer?
    private var startTime: Date = Date()

    // MARK: - Computed

    var totalRegions: Int { CCBodyRegion.all.count }
    var totalDuration: Int { totalRegions * regionDuration }

    var progress: Double {
        Double(currentRegionIndex * regionDuration + secondsInRegion) / Double(totalDuration)
    }

    var remainingSeconds: Int {
        totalDuration - totalElapsedSeconds
    }

    var formattedRemaining: String {
        let min = remainingSeconds / 60
        let sec = remainingSeconds % 60
        return String(format: "%d:%02d", min, sec)
    }

    var formattedTotal: String {
        let min = totalDuration / 60
        let sec = totalDuration % 60
        return String(format: "%d:%02d", min, sec)
    }

    var currentRegion: CCBodyRegion? {
        guard currentRegionIndex < CCBodyRegion.all.count else { return nil }
        return CCBodyRegion.all[currentRegionIndex]
    }

    var isActive: Bool {
        if case .scanning = phase { return true }
        return false
    }

    var completionMessage: String {
        let noteCount = sensationNotes.values.filter { !$0.isEmpty }.count
        if noteCount >= 5 {
            return "你记录了\(noteCount)个身体区域的感觉，这说明你对自己的身体有很好的觉察力。继续练习会让这种觉察越来越敏锐。"
        } else if noteCount > 0 {
            return "你开始了身体觉察的旅程。每一次扫描都是与身体重新连接的机会。"
        } else {
            return "完成身体扫描本身就是一种成就。下次可以尝试记录一些身体感觉，加深觉察。"
        }
    }

    // MARK: - Actions

    func start() {
        guard case .idle = phase else { return }
        startTime = Date()
        currentRegionIndex = 0
        totalElapsedSeconds = 0
        secondsInRegion = 0
        isPaused = false
        phase = .scanning(regionIndex: 0)
        startTimer()
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func reset() {
        stopTimer()
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .idle
            currentRegionIndex = 0
            secondsInRegion = 0
            totalElapsedSeconds = 0
            isPaused = false
        }
    }

    func setNote(for regionId: String, note: String) {
        sensationNotes[regionId] = note
    }

    func updateRegionDuration(_ seconds: Int) {
        regionDuration = max(15, min(60, seconds))
    }

    func skipToNextRegion() {
        advanceRegion()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard !isPaused else { return }
        secondsInRegion += 1
        totalElapsedSeconds += 1

        if secondsInRegion >= regionDuration {
            advanceRegion()
        }
    }

    private func advanceRegion() {
        currentRegionIndex += 1
        secondsInRegion = 0

        if currentRegionIndex >= totalRegions {
            completeScan()
        } else {
            phase = .scanning(regionIndex: currentRegionIndex)
        }
    }

    private func completeScan() {
        stopTimer()
        phase = .completed
        let duration = Int(Date().timeIntervalSince(startTime))
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "body_scan",
                duration: duration,
                completed: true
            )
        }
    }
}
