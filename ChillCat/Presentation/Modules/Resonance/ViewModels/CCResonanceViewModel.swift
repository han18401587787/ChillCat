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
        print("🔄 [Resonance] loadResonance start")
        isLoading = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list)
            onlineCount = 0
            hasMore = page.total > resonanceItems.count
            if resonanceItems.isEmpty { resonanceItems = [] }
            print("✅ [Resonance] loadResonance done: \(resonanceItems.count) items, \(onlineCount) online")
        } catch {
            self.error = error
            if resonanceItems.isEmpty { resonanceItems = [] }
            print("❌ [Resonance] loadResonance failed: \(error)")
        }
        isLoading = false
    }

    func refresh() async {
        print("🔄 [Resonance] refresh start")
        isRefreshing = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list)
            onlineCount = 0
            hasMore = page.total > resonanceItems.count
            print("✅ [Resonance] refresh done: \(resonanceItems.count) items")
        } catch {
            self.error = error
            print("❌ [Resonance] refresh failed: \(error)")
        }
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        print("🔄 [Resonance] loadMore start page=\(currentPage + 1)")
        isLoadingMore = true; currentPage += 1
        do {
            let page = try await CCXuanAPI.listResonance(page: currentPage)
            resonanceItems += mapItems(page.list)
            hasMore = page.total > resonanceItems.count
            print("✅ [Resonance] loadMore done: +\(page.list.count) items, total=\(resonanceItems.count)")
        } catch {
            currentPage -= 1
            print("❌ [Resonance] loadMore failed: \(error)")
        }
        isLoadingMore = false
    }

    private func mapItems(_ list: [CCXuanAPI.ResonanceItem]) -> [CCResonanceDisplayItem] {
        list.map { p in
            CCResonanceDisplayItem(
                id: String(p.id),
                content: p.content,
                emotion: p.emotion,
                emotionColor: p.emotionColor,
                isAnonymous: p.isAnonymous,
                displayName: p.displayName,
                resonanceCount: Int(p.resonanceCount),
                createdAt: ISO8601DateFormatter().date(from: p.createdAt) ?? Date()
            )
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
                print("✅ [Resonance] publishPost done")
                await loadResonance()
            } catch {
                print("❌ [Resonance] publishPost failed: \(error)")
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
