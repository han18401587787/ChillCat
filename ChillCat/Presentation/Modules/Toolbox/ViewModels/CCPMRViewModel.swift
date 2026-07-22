//
//  CCPMRViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 渐进式肌肉放松 ViewModel
//

import Foundation
import SwiftUI
import Combine

// MARK: - Muscle Group Model

struct CCMuscleGroup: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let instruction: String

    static let all: [CCMuscleGroup] = [
        .init(id: 0, name: "双手", icon: "hand.raised.fill", instruction: "用力握紧双拳，感受手部的紧张感"),
        .init(id: 1, name: "前臂", icon: "figure.arms.open", instruction: "弯曲手腕，绷紧前臂肌肉"),
        .init(id: 2, name: "上臂", icon: "figure.strengthtraining.traditional", instruction: "收紧肱二头肌，让上臂紧张"),
        .init(id: 3, name: "肩膀", icon: "figure.mind.and.body", instruction: "耸起双肩靠近耳朵，感受肩部的紧绷"),
        .init(id: 4, name: "额头", icon: "face.smiling", instruction: "用力抬高眉毛，让额头产生皱纹"),
        .init(id: 5, name: "眼睛", icon: "eye.fill", instruction: "紧闭双眼，感受眼周的紧张感"),
        .init(id: 6, name: "下巴", icon: "mouth.fill", instruction: "咬紧牙关，感受下颌的张力"),
        .init(id: 7, name: "颈部", icon: "person.fill", instruction: "低头让下巴靠近胸口，感受颈部的拉伸"),
        .init(id: 8, name: "胸部", icon: "heart.fill", instruction: "深吸一口气，收紧胸部肌肉"),
        .init(id: 9, name: "腹部", icon: "circle.fill", instruction: "收紧腹部肌肉，像准备承受一拳"),
        .init(id: 10, name: "背部", icon: "figure.walk", instruction: "向后收紧肩胛骨，感受背部的张力"),
        .init(id: 11, name: "臀部", icon: "figure.seated.seatbelt", instruction: "夹紧臀部肌肉，保持收紧"),
        .init(id: 12, name: "大腿", icon: "figure.walk", instruction: "伸直双腿，绷紧大腿前侧肌肉"),
        .init(id: 13, name: "小腿", icon: "figure.walk.departure", instruction: "脚尖指向身体方向，拉伸小腿"),
        .init(id: 14, name: "脚踝", icon: "figure.walk.arrival", instruction: "转动脚踝，感受脚踝的紧张"),
        .init(id: 15, name: "脚趾", icon: "shoeprints.fill", instruction: "用力蜷缩脚趾，感受足底的紧张"),
    ]
}

// MARK: - PMR Phase

enum CCPMRPhase: Equatable {
    case idle
    case tense(groupIndex: Int)
    case release(groupIndex: Int)
    case completed
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCPMRViewModel {
    // State
    var phase: CCPMRPhase = .idle
    var currentGroupIndex: Int = 0
    var secondsInPhase: Int = 0
    var totalElapsedSeconds: Int = 0
    var isPaused: Bool = false
    var bodyFeelingRating: Double = 5

    // Timer
    private var timer: Timer?
    private var startTime: Date = Date()

    // Constants
    let tenseDuration: Int = 5
    let releaseDuration: Int = 10
    let totalGroups: Int = CCMuscleGroup.all.count

    // MARK: - Computed

    var totalDuration: Int {
        totalGroups * (tenseDuration + releaseDuration)
    }

    var progress: Double {
        Double(currentGroupIndex * (tenseDuration + releaseDuration) + secondsInPhase)
            / Double(totalDuration)
    }

    var remainingSeconds: Int {
        totalDuration - totalElapsedSeconds
    }

    var formattedRemaining: String {
        let min = remainingSeconds / 60
        let sec = remainingSeconds % 60
        return String(format: "%d:%02d", min, sec)
    }

    var currentMuscleGroup: CCMuscleGroup? {
        guard currentGroupIndex < CCMuscleGroup.all.count else { return nil }
        return CCMuscleGroup.all[currentGroupIndex]
    }

    var isTense: Bool {
        if case .tense = phase { return true }
        return false
    }

    var isRelease: Bool {
        if case .release = phase { return true }
        return false
    }

    var phaseLabel: String {
        switch phase {
        case .idle: return "准备开始"
        case .tense: return "紧张 \(secondsInPhase)/\(tenseDuration)s"
        case .release: return "放松 \(secondsInPhase)/\(releaseDuration)s"
        case .completed: return "完成"
        }
    }

    var phaseDescription: String {
        switch phase {
        case .idle: return "按开始按钮，开始渐进式肌肉放松练习"
        case .tense: return currentMuscleGroup?.instruction ?? "收紧肌肉"
        case .release: return "慢慢放松...感受肌肉从紧张到松弛的变化"
        case .completed: return "你已经完成了全部16个肌群的放松练习"
        }
    }

    var breathingScale: Double {
        switch phase {
        case .tense:
            return 1.0 - (Double(secondsInPhase) / Double(tenseDuration)) * 0.3
        case .release:
            return 0.7 + (Double(secondsInPhase) / Double(releaseDuration)) * 0.3
        default:
            return 0.7
        }
    }

    var completionMessage: String {
        if bodyFeelingRating <= 3 {
            return "你的身体感到非常放松。继续保持这种状态，你会睡得更香、心情更好。"
        } else if bodyFeelingRating <= 6 {
            return "身体还有一点紧张是正常的。每天练习会让放松越来越深入。"
        } else {
            return "注意到身体的紧张已经是重要的第一步。试试深呼吸几次，帮助身体进一步放松。"
        }
    }

    // MARK: - Actions

    func start() {
        guard case .idle = phase else { return }
        startTime = Date()
        currentGroupIndex = 0
        totalElapsedSeconds = 0
        isPaused = false
        startTensePhase()
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
            currentGroupIndex = 0
            secondsInPhase = 0
            totalElapsedSeconds = 0
            isPaused = false
            bodyFeelingRating = 5
        }
    }

    // MARK: - Timer Logic

    private func startTensePhase() {
        secondsInPhase = 0
        phase = .tense(groupIndex: currentGroupIndex)
        startTimer()
    }

    private func startReleasePhase() {
        secondsInPhase = 0
        phase = .release(groupIndex: currentGroupIndex)
        startTimer()
    }

    private func advanceGroup() {
        currentGroupIndex += 1
        if currentGroupIndex >= totalGroups {
            completeExercise()
        } else {
            startTensePhase()
        }
    }

    private func completeExercise() {
        stopTimer()
        phase = .completed
        let duration = Int(Date().timeIntervalSince(startTime))
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "progressive_muscle_relaxation",
                duration: duration,
                completed: true
            )
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard !isPaused else { return }
        secondsInPhase += 1
        totalElapsedSeconds += 1

        switch phase {
        case .tense:
            if secondsInPhase >= tenseDuration {
                startReleasePhase()
            }
        case .release:
            if secondsInPhase >= releaseDuration {
                advanceGroup()
            }
        default:
            break
        }
    }
}
