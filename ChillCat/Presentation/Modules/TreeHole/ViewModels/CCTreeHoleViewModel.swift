import Foundation
import SwiftUI

@MainActor @Observable
final class CCTreeHoleViewModel {
    var isAnonymous: Bool = true
    var posts: [CCTreeHolePost] = []
    var newPostText: String = ""
    var selectedScope: CCPostScope = .public
    var isLoading = false

    init() { Task { await loadPosts() } }

    func loadPosts() async {
        isLoading = true
        do {
            let page = try await CCXuanAPI.listPosts()
            posts = page.list.map { p in
                CCTreeHolePost(id: String(p.id), content: p.content,
                    scope: p.scope == "public" ? .public : .comforters,
                    isAnonymous: p.isAnonymous, hugs: Int(p.hugs),
                    createdAt: ISO8601DateFormatter().date(from: p.createdAt) ?? Date())
            }
        } catch {}
        isLoading = false
    }

    func toggleAnonymous() { isAnonymous.toggle() }
    func publishPost() {
        guard !newPostText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let text = newPostText; newPostText = ""
        let scope = selectedScope; let anon = isAnonymous
        Task {
            do {
                let _ = try await CCXuanAPI.createPost(content: text, scope: scope == .public ? "public" : "comforters", isAnonymous: anon)
                await loadPosts()
            } catch {}
        }
    }

    func hugPost(_ post: CCTreeHolePost) {
        guard let id = Int64(post.id) else { return }
        Task {
            try? await CCXuanAPI.hugPost(id: id)
            if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                posts[idx].hugs += 1
            }
        }
    }
}

struct CCTreeHolePost: Identifiable, Hashable {
    let id: String; let content: String; let scope: CCPostScope
    let isAnonymous: Bool; var hugs: Int; let createdAt: Date
    var displayName: String { isAnonymous ? "匿名用户" : "我" }
    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }; if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }; return "\(Int(d/86400))天前"
    }
}

enum CCPostScope: String, CaseIterable, Hashable { case `public` = "社区公开"; case comforters = "仅安慰者" }
