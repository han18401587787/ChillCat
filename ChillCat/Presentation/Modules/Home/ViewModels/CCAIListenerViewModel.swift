//
//  CCAIListenerViewModel.swift
//  绪安 - AI 情绪倾听官
//

import Foundation
import SwiftUI
import Combine

/// AI 回应消息模型
struct CCAIResponseMessage: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let text: String
    var feedback: CCAIFeedbackState?
}

enum CCAIFeedbackState: Equatable {
    case helpful
    case notHelpful
}

// MARK: - 对话模式

/// AI 倾听官的四种对话模式
enum CCAIChatMode: String, CaseIterable, Equatable {
    case listening   = "倾诉"
    case exploring   = "探索"
    case guiding     = "指导"
    case crisis      = "危机"

    var emoji: String {
        switch self {
        case .listening:  return "💬"
        case .exploring:  return "🔍"
        case .guiding:    return "🧭"
        case .crisis:     return "🛡️"
        }
    }

    var displayName: String {
        self.rawValue
    }

    /// 模式对应的 placeholder 轮播文案
    var placeholders: [String] {
        switch self {
        case .listening:
            return [
                "随便说说，我在听…",
                "今天发生了什么？",
                "有什么想说的？",
                "我在这里听",
            ]
        case .exploring:
            return [
                "是什么让你有这样的感受？",
                "试着描述一下那个时刻…",
                "这种感受持续多久了？",
                "当时你在想什么？",
            ]
        case .guiding:
            return [
                "试着换个角度看看这件事…",
                "如果朋友遇到同样的事，你会怎么说？",
                "有什么证据支持/反对这个想法？",
                "最坏的结果真的会发生吗？",
            ]
        case .crisis:
            return [
                "我在这里，你是安全的。告诉我发生了什么？",
                "你的感受很重要，我愿意陪你。",
                "现在最让你痛苦的是什么？",
            ]
        }
    }
}

// MARK: - 风险等级

/// 用户情绪风险评估等级
enum CCAIRiskLevel: Int, Comparable, Equatable {
    case none   = 0
    case low    = 1
    case medium = 2
    case high   = 3

    static func < (lhs: CCAIRiskLevel, rhs: CCAIRiskLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 危机关键词检测

private enum CCCrisisKeyword {
    /// 高风险关键词 → riskLevel = .high
    static let highRisk: Set<String> = [
        "自杀", "自伤", "不想活", "结束生命",
        "去死", "跳楼", "割腕", "寻死",
    ]
    /// 中等风险关键词 → riskLevel = .medium
    static let mediumRisk: Set<String> = [
        "绝望", "没有意义", "伤害自己",
        "活不下去了", "受不了了", "崩溃了",
    ]
    /// 低风险关键词 → riskLevel = .low
    static let lowRisk: Set<String> = [
        "很痛苦", "太难了", "不想面对",
        "压力太大", "撑不住了", "很绝望",
    ]
}

@MainActor
@Observable
final class CCAIListenerViewModel {
    var inputText: String = ""
    var aiResponses: [CCAIResponseMessage] = []
    var isLoading = false

    // MARK: - 对话模式 & 危机状态

    /// 当前对话模式（默认 listening，保持向后兼容）
    var currentMode: CCAIChatMode = .listening

    /// 是否检测到危机内容
    var crisisDetected = false

    /// 是否显示安全计划页面
    var showSafetyPlan = false

    /// 是否显示热线电话 Sheet
    var showHotlineSheet = false

    /// 当前风险评估等级
    var riskLevel: CCAIRiskLevel = .none

    /// Placeholder 轮播
    var currentPlaceholder: String = "随便说说，我在听…"
    private var placeholderIndex = 0
    private var placeholderTimer: Timer?

    /// 当前模式对应的 placeholder 列表
    private var modePlaceholders: [String] {
        currentMode.placeholders
    }
    /// 发送按钮激活条件：≥ 3 个字
    var isSendEnabled: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    /// AI 默认回应库（离线回退 / preview）
    private static let fallbackResponses: [(emoji: String, text: String)] = [
        ("💚", "被批评的感觉确实不好受。"),
        ("🌿", "你已经很努力了。"),
        ("🕊️", "愿意多说一点吗？"),
    ]

    // MARK: - Lifecycle

    init() {
        currentPlaceholder = modePlaceholders.first ?? "随便说说，我在听…"
        startPlaceholderRotation()
    }

    deinit {
        MainActor.assumeIsolated {
            placeholderTimer?.invalidate()
        }
    }

    // MARK: - Placeholder Rotation

    private func startPlaceholderRotation() {
        placeholderTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let phs = self.modePlaceholders
                guard !phs.isEmpty else { return }
                self.placeholderIndex = (self.placeholderIndex + 1) % phs.count
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.currentPlaceholder = phs[self.placeholderIndex]
                }
            }
        }
    }

    // MARK: - Send & AI Response

    func sendMessage() {
        guard isSendEnabled else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✦ 危机关键词检测
        let detectedRisk = detectRiskLevel(from: text)
        if detectedRisk > riskLevel {
            riskLevel = detectedRisk
        }
        if detectedRisk >= .medium {
            crisisDetected = true
            currentMode = .crisis
        }

        // Reset state
        aiResponses = []
        isLoading = true
        inputText = ""

        Task {
            await fetchAIResponse(for: text, riskLevel: detectedRisk)
        }
    }

    /// 根据输入文本检测风险等级
    private func detectRiskLevel(from text: String) -> CCAIRiskLevel {
        // 高风险优先检测
        for keyword in CCCrisisKeyword.highRisk where text.contains(keyword) {
            return .high
        }
        for keyword in CCCrisisKeyword.mediumRisk where text.contains(keyword) {
            return .medium
        }
        for keyword in CCCrisisKeyword.lowRisk where text.contains(keyword) {
            return .low
        }
        return .none
    }

    private func fetchAIResponse(for text: String, riskLevel: CCAIRiskLevel) async {
        let watchdogID = CCLoadingWatchdog.shared.startWatching(label: "AIListener.fetchResponse")
        defer { CCLoadingWatchdog.shared.stopWatching(watchdogID) }

        do {
            let resp = try await CCXuanAPI.getEmpathyResponses(text: text)
            if resp.responses.isEmpty {
                LogW("AI 共情接口返回空响应列表", module: .ui, category: "AIListener")
            }
            await deliverResponses(resp.responses)
            // 危机模式下追加安全提示
            if riskLevel >= .medium {
                await deliverCrisisSafetyMessage()
            }
        } catch {
            // 网络失败时使用本地回退回应
            LogW("AI 共情接口失败，使用本地兜底: \(error.localizedDescription)", module: .ui, category: "AIListener")
            let fallbackTexts = Self.fallbackResponses.map { $0.text }
            await deliverResponses(fallbackTexts)
            if riskLevel >= .medium {
                await deliverCrisisSafetyMessage()
            }
        }
        isLoading = false
    }

    /// 危机模式下追加安全提示与热线信息
    private func deliverCrisisSafetyMessage() async {
        let safetyMessage = CCAIResponseMessage(
            emoji: "🛡️",
            text: "你的安全最重要。如果你正在经历痛苦，请拨打：24小时心理援助热线 400-161-9995 | 北京心理危机研究与干预中心 010-82951332。我愿意在这里陪着你。"
        )
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
        withAnimation(.easeInOut(duration: 0.4)) {
            aiResponses.append(safetyMessage)
        }
    }

    /// 逐条动画出现（每条延迟 0.8s）
    private func deliverResponses(_ texts: [String]) async {
        let emojis = Self.fallbackResponses.map { $0.emoji }
        for (index, text) in texts.enumerated() {
            let emoji = emojis[safe: index] ?? "💚"
            let message = CCAIResponseMessage(emoji: emoji, text: text)
            withAnimation(.easeInOut(duration: 0.4)) {
                aiResponses.append(message)
            }
            if index < texts.count - 1 {
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
            }
        }
    }

    // MARK: - Feedback

    func submitFeedback(for message: CCAIResponseMessage, isHelpful: Bool) {
        guard let idx = aiResponses.firstIndex(where: { $0.id == message.id }) else { return }
        aiResponses[idx].feedback = isHelpful ? .helpful : .notHelpful

        // Fire-and-forget to backend
        Task {
            try? await CCXuanAPI.sendEmpathyFeedback(
                responseIndex: idx,
                helpful: isHelpful
            )
        }
    }

    // MARK: - Mode Switching

    /// 切换对话模式
    func switchMode(_ mode: CCAIChatMode) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMode = mode
            // 切换模式时重置 placeholder
            placeholderIndex = 0
            currentPlaceholder = modePlaceholders.first ?? "随便说说，我在听…"
        }
        // 非危机模式下重置危机状态（用户主动切换回倾听/探索/指导）
        if mode != .crisis {
            crisisDetected = false
            riskLevel = .none
        }
    }

    // MARK: - Reset

    func reset() {
        inputText = ""
        aiResponses = []
        isLoading = false
        // 重置危机状态
        crisisDetected = false
        riskLevel = .none
        currentMode = .listening
        placeholderIndex = 0
        currentPlaceholder = modePlaceholders.first ?? "随便说说，我在听…"
    }
}
