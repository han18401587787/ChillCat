import Foundation
import SwiftUI

@MainActor @Observable
final class CCEmotionDecoderViewModel {
    var inputText: String = ""
    var surfaceEmotion: DecodeLayer?
    var middleEmotions: [DecodeLayer] = []
    var deepNeeds: [DecodeLayer] = []
    var suggestions: [DecodeSuggestion] = []
    var isLoading = false
    var errorMessage: String?
    var showResult = false

    // Animation control
    var showSurface = false
    var showMiddle = false
    var showDeep = false
    var showSuggestions = false

    var canDecode: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    func decode() async {
        guard canDecode else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        isLoading = true
        errorMessage = nil
        showResult = false
        showSurface = false
        showMiddle = false
        showDeep = false
        showSuggestions = false

        do {
            let result = try await CCXuanAPI.decodeEmotion(text: text)
            surfaceEmotion = DecodeLayer(
                label: result.surfaceEmotion.label,
                icon: result.surfaceEmotion.icon,
                confidence: result.surfaceEmotion.confidence
            )
            middleEmotions = result.middleEmotions.map {
                DecodeLayer(label: $0.label, icon: $0.icon, confidence: $0.confidence)
            }
            deepNeeds = result.deepNeeds.map {
                DecodeLayer(label: $0.label, icon: $0.icon, confidence: $0.confidence)
            }
            suggestions = result.suggestions.map {
                DecodeSuggestion(type: $0.type, title: $0.title, description: $0.description)
            }
            showResult = true

            // Animate layers sequentially
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { showSurface = true }
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { showMiddle = true }
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { showDeep = true }
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { showSuggestions = true }
        } catch {
            errorMessage = "解码失败，请再试一次"
        }
        isLoading = false
    }

    func reset() {
        inputText = ""
        surfaceEmotion = nil
        middleEmotions = []
        deepNeeds = []
        suggestions = []
        showResult = false
        showSurface = false
        showMiddle = false
        showDeep = false
        showSuggestions = false
        errorMessage = nil
    }
}

struct DecodeLayer: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let confidence: Double?
}

struct DecodeSuggestion: Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let description: String

    var iconName: String {
        switch type {
        case "meditation": return "wind"
        case "journal": return "square.and.pencil"
        case "book": return "book.pages.fill"
        case "breathing": return "lungs.fill"
        case "exercise": return "figure.walk"
        default: return "lightbulb.fill"
        }
    }

    var colorName: String {
        switch type {
        case "meditation": return "softPurple"
        case "journal": return "softPink"
        case "book": return "warmLight"
        case "breathing": return "softGreen"
        case "exercise": return "softGreen"
        default: return "primaryMuted"
        }
    }
}
