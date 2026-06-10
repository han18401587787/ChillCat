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
        isLoading = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list)
            onlineCount = page.onlineCount
            hasMore = page.total > resonanceItems.count
            if resonanceItems.isEmpty { resonanceItems = [] }
        } catch {
            self.error = error
            if resonanceItems.isEmpty { resonanceItems = [] }
        }
        isLoading = false
    }

    func refresh() async {
        isRefreshing = true; error = nil; currentPage = 1
        do {
            let page = try await CCXuanAPI.listResonance(page: 1)
            resonanceItems = mapItems(page.list)
            onlineCount = page.onlineCount
            hasMore = page.total > resonanceItems.count
        } catch { self.error = error }
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true; currentPage += 1
        do {
            let page = try await CCXuanAPI.listResonance(page: currentPage)
            resonanceItems += mapItems(page.list)
            hasMore = page.total > resonanceItems.count
        } catch { currentPage -= 1 }
        isLoadingMore = false
    }

    private func mapItems(_ list: [CCXuanAPI.ResonanceItem]) -> [CCResonanceDisplayItem] {
        list.map { item in
            CCResonanceDisplayItem(
                id: String(item.id),
                content: item.content,
                emotion: item.emotion,
                emotionColor: item.emotionColor,
                isAnonymous: item.isAnonymous,
                displayName: item.displayName,
                resonanceCount: Int(item.resonanceCount),
                createdAt: ISO8601DateFormatter().date(from: item.createdAt) ?? Date()
            )
        }
    }

    func hugResonance(_ item: CCResonanceDisplayItem) {
        guard let id = Int64(item.id) else { return }
        Task {
            try? await CCXuanAPI.hugResonance(id: id)
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
                await loadResonance()
            } catch {
                // Silently handle — the post list stays
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
