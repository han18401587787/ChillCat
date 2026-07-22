//
//  CCValuesExplorerViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 价值观探索 ViewModel
//

import Foundation
import SwiftUI
import Combine

// MARK: - Value Card Model

struct CCValueCard: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let description: String

    static let all: [CCValueCard] = [
        .init(id: "family", name: "家庭", emoji: "👨‍👩‍👧‍👦", description: "与家人保持亲密的关系"),
        .init(id: "career", name: "事业", emoji: "💼", description: "在工作中取得成就和认可"),
        .init(id: "growth", name: "成长", emoji: "🌱", description: "持续学习和自我提升"),
        .init(id: "freedom", name: "自由", emoji: "🕊️", description: "按照自己的方式生活"),
        .init(id: "relationships", name: "关系", emoji: "💝", description: "建立深厚的人际连接"),
        .init(id: "health", name: "健康", emoji: "💪", description: "保持身心健康和活力"),
        .init(id: "creativity", name: "创造力", emoji: "🎨", description: "表达独特的创意和想法"),
        .init(id: "security", name: "安全感", emoji: "🏠", description: "拥有稳定和安全的生活"),
        .init(id: "adventure", name: "冒险", emoji: "🏔️", description: "探索未知、体验新鲜事物"),
        .init(id: "contribution", name: "贡献", emoji: "🤝", description: "为社会和他人带来价值"),
        .init(id: "wisdom", name: "智慧", emoji: "📚", description: "追求知识和深刻的理解"),
        .init(id: "happiness", name: "快乐", emoji: "😄", description: "享受生活，保持积极心态"),
        .init(id: "authenticity", name: "真实", emoji: "💎", description: "做真实的自己，不伪装"),
        .init(id: "independence", name: "独立", emoji: "🦅", description: "自力更生，不依赖他人"),
        .init(id: "connection", name: "连接", emoji: "🌐", description: "感受与他人和世界的联系"),
        .init(id: "peace", name: "平和", emoji: "☮️", description: "保持内心的宁静与和谐"),
        .init(id: "courage", name: "勇气", emoji: "🦁", description: "面对恐惧，勇敢前行"),
        .init(id: "fairness", name: "公平", emoji: "⚖️", description: "追求正义和平等"),
        .init(id: "spirituality", name: "灵性", emoji: "🧘", description: "探索精神世界和意义"),
        .init(id: "beauty", name: "美丽", emoji: "🌸", description: "欣赏和创造美的事物"),
    ]
}

// MARK: - Values Explorer Step

enum CCValuesStep: Int, CaseIterable {
    case selectTen = 0
    case rankTopFive = 1
    case reflectOnValues = 2
    case rateAlignment = 3
    case actionPlan = 4
    case completed = 5

    var title: String {
        switch self {
        case .selectTen: return "选择你重视的价值观"
        case .rankTopFive: return "排列最重要的5个"
        case .reflectOnValues: return "价值观反思"
        case .rateAlignment: return "行为一致性评估"
        case .actionPlan: return "制定行动方案"
        case .completed: return "探索完成"
        }
    }

    var subtitle: String {
        switch self {
        case .selectTen: return "从20个价值观中选择10个你认为最重要的（可多选）"
        case .rankTopFive: return "从已选的10个中，拖拽排列出最重要的5个"
        case .reflectOnValues: return "对每个最重要的价值观，写下你在做什么时体现了它"
        case .rateAlignment: return "评估你当前的行为与价值观的一致性"
        case .actionPlan: return "写下一个小行动，让你更接近你的价值观"
        case .completed: return "你已经完成了价值观探索"
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCValuesExplorerViewModel {
    var currentStep: CCValuesStep = .selectTen
    var selectedValues: Set<String> = []
    var rankedValues: [String] = []
    var valueReflections: [String: String] = [:]
    var alignmentRating: Double = 5
    var actionPlan: String = ""
    var isCompleted: Bool = false
    var startTime: Date = Date()

    // For ranking: selected subset that user can reorder
    var topFiveRanking: [String] {
        get { rankedValues }
        set { rankedValues = newValue }
    }

    // MARK: - Computed

    var stepProgress: Double {
        Double(currentStep.rawValue) / Double(CCValuesStep.allCases.count - 1)
    }

    var canProceedSelect: Bool {
        selectedValues.count >= 5 && selectedValues.count <= 10
    }

    var canProceedRank: Bool {
        rankedValues.count == 5
    }

    var canProceedReflect: Bool {
        // All 5 ranked values have a non-empty reflection
        rankedValues.allSatisfy { id in
            !(valueReflections[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var canProceedRate: Bool {
        true  // Always allowed
    }

    var canProceedAction: Bool {
        !actionPlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var alignmentDescription: String {
        switch Int(alignmentRating) {
        case 1...3: return "你的行为和价值观之间差距较大，这是改变的开始。"
        case 4...6: return "你在某些方面已经与价值观保持一致，还有提升空间。"
        case 7...8: return "你的生活与价值观有较好的一致性，继续保持！"
        case 9...10: return "你的行为和价值观高度一致，你正活出真实的自己。"
        default: return ""
        }
    }

    var completionMessage: String {
        let topValueName = rankedValues.first.flatMap { id in
            CCValueCard.all.first { $0.id == id }?.name
        } ?? ""

        if !topValueName.isEmpty {
            return "「\(topValueName)」是你最重要的价值观。当你的行为与价值观一致时，你会感到更加充实和有意义。今天的探索是活出真实自我的第一步。"
        }
        return "你已经完成了价值观探索。了解自己的价值观是自我认知的重要一步，它会指引你做出更符合内心的选择。"
    }

    // MARK: - Actions

    func toggleValue(_ valueId: String) {
        if selectedValues.contains(valueId) {
            selectedValues.remove(valueId)
        } else if selectedValues.count < 10 {
            selectedValues.insert(valueId)
        }
    }

    func goToNextStep() {
        guard let next = CCValuesStep(rawValue: currentStep.rawValue + 1) else { return }

        // When transitioning from select to rank, initialize ranked with first 5 selected
        if next == .rankTopFive && rankedValues.isEmpty {
            rankedValues = Array(selectedValues.prefix(5))
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = next
        }

        if next == .completed {
            isCompleted = true
            recordCompletion()
        }
    }

    func goToPreviousStep() {
        guard let prev = CCValuesStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = prev
        }
    }

    func moveRankedValue(from source: IndexSet, to destination: Int) {
        rankedValues.move(fromOffsets: source, toOffset: destination)
    }

    func setReflection(for valueId: String, text: String) {
        valueReflections[valueId] = text
    }

    func reset() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .selectTen
            selectedValues = []
            rankedValues = []
            valueReflections = [:]
            alignmentRating = 5
            actionPlan = ""
            isCompleted = false
            startTime = Date()
        }
    }

    private func recordCompletion() {
        let duration = Int(Date().timeIntervalSince(startTime))
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "values_explorer",
                duration: duration,
                completed: true
            )
        }
    }
}
