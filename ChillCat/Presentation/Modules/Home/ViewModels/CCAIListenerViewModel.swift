//
//  CCAIListenerViewModel.swift
//  绪安 - AI 情绪倾听官
//

import Foundation
import SwiftUI

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

@MainActor
@Observable
final class CCAIListenerViewModel {
    var inputText: String = ""
    var aiResponses: [CCAIResponseMessage] = []
    var isLoading = false
    var errorMessage: String?
    var hasReceivedResponse = false

    /// Placeholder 轮播
    var currentPlaceholder: String = "随便说说，我在听…"
    private var placeholderIndex = 0
    private var placeholderTimer: Timer?

    private let placeholders = CCAIListenerViewModel.placeholders
    static let placeholders = [
        "随便说说，我在听…",
        "今天发生了什么？",
        "有什么想说的？",
        "我在这里听",
    ]

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
                self.placeholderIndex = (self.placeholderIndex + 1) % self.placeholders.count
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.currentPlaceholder = self.placeholders[self.placeholderIndex]
                }
            }
        }
    }

    // MARK: - Send & AI Response

    func sendMessage() {
        guard isSendEnabled else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Reset state
        aiResponses = []
        errorMessage = nil
        hasReceivedResponse = false
        isLoading = true
        inputText = ""

        Task {
            await fetchAIResponse(for: text)
        }
    }

    private func fetchAIResponse(for text: String) async {
        do {
            let resp = try await CCXuanAPI.getEmpathyResponses(text: text)
            await deliverResponses(resp.responses)
        } catch {
            // 网络失败时使用本地回退回应
            let fallbackTexts = Self.fallbackResponses.map { $0.text }
            await deliverResponses(fallbackTexts)
        }
        isLoading = false
        hasReceivedResponse = true
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

    // MARK: - Reset

    func reset() {
        inputText = ""
        aiResponses = []
        isLoading = false
        errorMessage = nil
        hasReceivedResponse = false
    }
}
