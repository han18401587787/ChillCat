//
//  CCResonanceViewModel.swift
//  绪安 - 共鸣墙
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCResonanceViewModel {
    var resonanceItems: [CCResonanceDisplayItem] = []
    var onlineCount: Int64 = 0
    var isLoading = false
    var isRefreshing = false
    var isLoadingMore = false
    var hasMore = true
    var error: Error?
    private var currentPage = 1

    // Compose
    var newPostText: String = ""
    var isAnonymous: Bool = true

    func loadResonance() async {
        LogD("[Resonance] loadResonance start", module: .network, category: "Resonance")
        isLoading = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list ?? [])
            onlineCount = page.onlineCount ?? 0
            hasMore = (page.total ?? 0) > resonanceItems.count
            if resonanceItems.isEmpty { resonanceItems = [] }
            LogI("[Resonance] loadResonance done: \(resonanceItems.count) items, \(onlineCount) online", module: .network, category: "Resonance")
        } catch {
            self.error = error
            if resonanceItems.isEmpty { resonanceItems = [] }
            LogE("[Resonance] loadResonance failed: \(error)", module: .network, category: "Resonance")
        }
        isLoading = false
    }

    func refresh() async {
        LogD("[Resonance] refresh start", module: .network, category: "Resonance")
        isRefreshing = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list ?? [])
            onlineCount = page.onlineCount ?? 0
            hasMore = (page.total ?? 0) > resonanceItems.count
            LogI("[Resonance] refresh done: \(resonanceItems.count) items", module: .network, category: "Resonance")
        } catch {
            self.error = error
            LogE("[Resonance] refresh failed: \(error)", module: .network, category: "Resonance")
        }
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        LogD("[Resonance] loadMore start page=\(currentPage + 1)", module: .network, category: "Resonance")
        isLoadingMore = true; currentPage += 1
        do {
            let page = try await CCXuanAPI.listResonance(page: currentPage)
            let newItems = mapItems(page.list ?? [])
            resonanceItems += newItems
            hasMore = (page.total ?? 0) > resonanceItems.count
            LogI("[Resonance] loadMore done: +\(newItems.count) items, total=\(resonanceItems.count)", module: .network, category: "Resonance")
        } catch {
            currentPage -= 1
            LogE("[Resonance] loadMore failed: \(error)", module: .network, category: "Resonance")
        }
        isLoadingMore = false
    }

    private func mapItems(_ list: [CCXuanAPI.ResonanceItem]) -> [CCResonanceDisplayItem] {
        list.map { p in
            CCResonanceDisplayItem(
                id: String(p.id),
                content: p.content ?? "",
                emotion: p.emotionType ?? "平静",
                emotionColor: emotionColorFor(p.emotionType ?? "平静"),
                isAnonymous: p.isAnonymous ?? true,
                displayName: p.displayName ?? "匿名用户",
                resonanceCount: Int(p.resonanceCount ?? 0),
                createdAt: ISO8601DateFormatter().date(from: p.createdAt ?? "") ?? Date()
            )
        }
    }

    private func emotionColorFor(_ type: String) -> String {
        switch type {
        case "calm":    return "A8D9BA"
        case "happy":   return "D4A882"
        case "anxious": return "A085C6"
        case "wronged": return "F5A6BA"
        case "angry":   return "E67373"
        case "lonely":  return "63B5F5"
        case "tired":   return "B8D4E3"
        default:        return "A8D9BA"
        }
    }

    func hugResonance(_ item: CCResonanceDisplayItem, message: String? = nil) {
        guard let id = Int64(item.id) else { return }
        Task {
            try? await CCXuanAPI.hugResonance(id: id, message: message)
            if let idx = resonanceItems.firstIndex(where: { $0.id == item.id }) {
                resonanceItems[idx].resonanceCount += 1
            }
        }
    }

    func publishPost() {
        let text = newPostText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        newPostText = ""
        let anon = isAnonymous
        Task {
            do {
                let _ = try await CCXuanAPI.createResonancePost(
                    emotion: "平静", content: text, isAnonymous: anon
                )
                LogI("[Resonance] publishPost done", module: .network, category: "Resonance")
                await loadResonance()
            } catch {
                LogE("[Resonance] publishPost failed: \(error)", module: .network, category: "Resonance")
            }
        }
    }
}


/// Populated after loading detail (avoided re-defining a separate struct)
struct CCResonanceReplyDisplay: Identifiable, Hashable {
    let id: String
    let content: String
    let createdAt: Date
    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }
        return "\(Int(d/86400))天前"
    }
}

/// Typealias for CCResonanceWallDetailView compatibility
typealias CCResonanceWallPost = CCResonanceDisplayItem
