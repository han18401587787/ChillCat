import Foundation
import SwiftUI

@MainActor @Observable
final class CCEncourageChainViewModel {
    var chainId: Int64 = 0
    var links: [ChainLinkDisplay] = []
    var participantCount: Int64 = 0
    var relayText: String = ""
    var isLoading = false
    var isRelaying = false
    var errorMessage: String?

    // My chains
    var myChains: [ChainSummary] = []
    var isLoadingMyChains = false

    var canRelay: Bool {
        let trimmed = relayText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 140
    }

    var characterCount: Int {
        relayText.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    func loadCurrentChain() async {
        isLoading = true
        errorMessage = nil
        do {
            let chain = try await CCXuanAPI.getCurrentChain()
            chainId = chain.chainId
            links = chain.links.map {
                ChainLinkDisplay(
                    id: String($0.id),
                    content: $0.content,
                    position: $0.position,
                    createdAt: ISO8601DateFormatter().date(from: $0.createdAt) ?? Date()
                )
            }
            participantCount = chain.participantCount
            if links.isEmpty { links = ChainLinkDisplay.sampleLinks }
        } catch {
            if links.isEmpty { links = ChainLinkDisplay.sampleLinks }
            chainId = 2841
        }
        isLoading = false
    }

    func loadChain(id: Int64) async {
        isLoading = true
        errorMessage = nil
        do {
            let chain = try await CCXuanAPI.getChain(id: id)
            chainId = chain.chainId
            links = chain.links.map {
                ChainLinkDisplay(
                    id: String($0.id),
                    content: $0.content,
                    position: $0.position,
                    createdAt: ISO8601DateFormatter().date(from: $0.createdAt) ?? Date()
                )
            }
            participantCount = chain.participantCount
        } catch {
            errorMessage = "加载失败"
        }
        isLoading = false
    }

    func relayMessage() async {
        guard canRelay else { return }
        isRelaying = true
        errorMessage = nil
        let text = relayText.trimmingCharacters(in: .whitespacesAndNewlines)
        relayText = ""
        do {
            let _ = try await CCXuanAPI.participateInChain(content: text)
            await loadCurrentChain()
        } catch {
            errorMessage = "发送失败，请重试"
            relayText = text
        }
        isRelaying = false
    }

    func loadMyChains() async {
        isLoadingMyChains = true
        do {
            let chains = try await CCXuanAPI.getMyChains()
            myChains = chains.map {
                ChainSummary(
                    chainId: String($0.chainId),
                    firstMessage: $0.links.first?.content ?? "",
                    participantCount: Int($0.participantCount),
                    linkCount: $0.links.count
                )
            }
        } catch {}
        isLoadingMyChains = false
    }
}

struct ChainLinkDisplay: Identifiable, Hashable {
    let id: String
    let content: String
    let position: Int
    let createdAt: Date

    var displayIcon: String {
        if position == 1 { return "🌸" }
        else if position % 10 == 0 { return "🌟" }
        else { return ["💪", "🍀", "✨", "💚", "🕊️", "🌿", "🔥", "💖"].randomElement() ?? "💚" }
    }

    var label: String {
        switch position {
        case 1: return "起点"
        case ...10: return "接力"
        default: return "继续"
        }
    }

    static let sampleLinks: [ChainLinkDisplay] = [
        .init(id: "1", content: "今天我想鼓励每一个正在焦虑的人。你担心的事情，90%都不会发生。", position: 1, createdAt: Date().addingTimeInterval(-86400)),
        .init(id: "2", content: "谢谢！我今天正需要这个。也鼓励每一个在努力的人。", position: 2, createdAt: Date().addingTimeInterval(-72000)),
        .init(id: "3", content: "面试刚挂了，但看到这条觉得好多了。接力！", position: 3, createdAt: Date().addingTimeInterval(-36000)),
    ]
}

struct ChainSummary: Identifiable, Hashable {
    let chainId: String
    let firstMessage: String
    let participantCount: Int
    let linkCount: Int

    var id: String { chainId }
}
