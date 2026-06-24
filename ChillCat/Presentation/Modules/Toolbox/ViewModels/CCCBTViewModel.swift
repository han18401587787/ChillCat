//
//  CCCBTViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — CBT认知重构 ViewModel
//

import Foundation
import SwiftUI

// MARK: - Cognitive Distortion Model

struct CCCognitiveDistortion: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String

    static let all: [CCCognitiveDistortion] = [
        .init(id: "black_white", name: "非黑即白", description: "事情只有好坏两面，没有中间地带"),
        .init(id: "catastrophizing", name: "灾难化", description: "总是预期最坏的结果会发生"),
        .init(id: "overgeneralizing", name: "过度概括", description: "从单一事件得出普遍性结论"),
        .init(id: "mind_reading", name: "读心术", description: "认为自己知道别人在想什么"),
        .init(id: "should_statements", name: "应该陈述", description: "用'应该''必须'来要求自己或他人"),
        .init(id: "personalization", name: "个人化", description: "把外部事件归咎于自己"),
        .init(id: "emotional_reasoning", name: "情绪推理", description: "因为感觉如此就认为事实如此"),
        .init(id: "labeling", name: "贴标签", description: "用负面标签定义自己或他人"),
        .init(id: "discounting_positive", name: "否定积极", description: "忽视或贬低积极的经历"),
        .init(id: "mental_filter", name: "心理过滤", description: "只关注负面细节，忽略整体画面"),
    ]
}

// MARK: - CBT Exercise Step

enum CCCBTStep: Int, CaseIterable {
    case recordThought = 0
    case identifyDistortions = 1
    case reframeThought = 2
    case completed = 3

    var title: String {
        switch self {
        case .recordThought: return "记录自动思维"
        case .identifyDistortions: return "识别认知扭曲"
        case .reframeThought: return "重构合理思维"
        case .completed: return "练习完成"
        }
    }

    var subtitle: String {
        switch self {
        case .recordThought: return "描述发生了什么，以及你当时的自动想法"
        case .identifyDistortions: return "选择这个想法中包含的认知扭曲类型"
        case .reframeThought: return "用更平衡、更合理的角度重新看待这件事"
        case .completed: return "你已经完成了本次认知重构练习"
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCCBTViewModel {
    // Step tracking
    var currentStep: CCCBTStep = .recordThought

    // Step 1: Record automatic thought
    var situationText = ""
    var automaticThought = ""

    // Step 2: Identify distortions
    var selectedDistortions: Set<String> = []

    // Step 3: Reframe
    var balancedThought = ""
    var emotionBefore: Double = 5
    var emotionAfter: Double = 5

    // Completion
    var isCompleted = false
    var exerciseStartTime: Date = Date()

    // MARK: - Computed

    var stepProgress: Double {
        Double(currentStep.rawValue) / Double(CCCBTStep.allCases.count - 1)
    }

    var canProceedFromStep1: Bool {
        !situationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !automaticThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canProceedFromStep2: Bool {
        !selectedDistortions.isEmpty
    }

    var canProceedFromStep3: Bool {
        !balancedThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var emotionChangeDescription: String {
        let change = emotionAfter - emotionBefore
        if change > 2 {
            return "你的情绪有了显著改善！重构思维非常有效。"
        } else if change > 0 {
            return "你的情绪有所改善，继续练习会越来越好。"
        } else if change == 0 {
            return "情绪强度没有变化，但觉察本身就是一种进步。"
        } else {
            return "有时候写完反而更清晰了，这是正常的认知过程。"
        }
    }

    var completionMessage: String {
        if emotionAfter <= 3 {
            return "你已经成功将困扰你的情绪从 \(Int(emotionBefore)) 分降到了 \(Int(emotionAfter)) 分。认知重构的力量在于练习，每一次觉察都是进步。"
        } else {
            return "你完成了认知重构的三个步骤。记住，改变思维模式需要时间，今天的练习是重要的一步。"
        }
    }

    // MARK: - Actions

    func toggleDistortion(_ distortionId: String) {
        if selectedDistortions.contains(distortionId) {
            selectedDistortions.remove(distortionId)
        } else {
            selectedDistortions.insert(distortionId)
        }
    }

    func goToNextStep() {
        guard let next = CCCBTStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = next
        }
        if next == .completed {
            isCompleted = true
            recordCompletion()
        }
    }

    func goToPreviousStep() {
        guard let prev = CCCBTStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = prev
        }
    }

    func reset() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .recordThought
            situationText = ""
            automaticThought = ""
            selectedDistortions = []
            balancedThought = ""
            emotionBefore = 5
            emotionAfter = 5
            isCompleted = false
            exerciseStartTime = Date()
        }
    }

    private func recordCompletion() {
        let duration = Int(Date().timeIntervalSince(exerciseStartTime))
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "cbt_restructuring",
                duration: duration,
                completed: true
            )
        }
    }
}
