import Foundation
import SwiftUI

@MainActor @Observable
final class CCTreeHoleViewModel {
    var isAnonymous: Bool = true
    var posts: [CCTreeHolePost] = []
    var newPostText: String = ""
    var selectedScope: CCPostScope = .public
    var isLoading = false
    var isRefreshing = false
    var isLoadingMore = false
    var hasMore = true
    private var currentPage = 1

    init() {}

    func loadPosts() async {
        isLoading = true; currentPage = 1
        do {
            let page = try await CCXuanAPI.listPosts(page: 1)
            posts = mapPosts(page.list)
            hasMore = page.total > posts.count
            if posts.isEmpty { posts = CCTreeHolePost.samplePosts }
        } catch { if posts.isEmpty { posts = CCTreeHolePost.samplePosts } }
        isLoading = false
    }

    func refresh() async {
        isRefreshing = true; currentPage = 1
        do {
            let page = try await CCXuanAPI.listPosts(page: 1)
            posts = mapPosts(page.list)
            hasMore = page.total > posts.count
        } catch {}
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true; currentPage += 1
        do {
            let page = try await CCXuanAPI.listPosts(page: currentPage)
            posts += mapPosts(page.list)
            hasMore = page.total > posts.count
        } catch { currentPage -= 1 }
        isLoadingMore = false
    }

    private func mapPosts(_ list: [CCXuanAPI.PostResponse]) -> [CCTreeHolePost] {
        list.map { p in CCTreeHolePost(id: String(p.id), content: p.content,
            scope: p.scope == "public" ? .public : .comforters,
            isAnonymous: p.isAnonymous, hugs: Int(p.hugs),
            createdAt: ISO8601DateFormatter().date(from: p.createdAt) ?? Date()) }
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
    static let samplePosts: [CCTreeHolePost] = [
        .init(id: "1", content: "下午开会的时候leader当着所有人说我的方案不够细致，我知道他说的有道理，但就是委屈…", scope: .public, isAnonymous: true, hugs: 24, createdAt: Date().addingTimeInterval(-3600)),
        .init(id: "2", content: "周末去了公园，坐在草地上发呆了一个小时，脑子难得空空的，感觉很舒服。", scope: .public, isAnonymous: true, hugs: 18, createdAt: Date().addingTimeInterval(-7200)),
        .init(id: "3", content: "为什么明明没做错，还是觉得对不起所有人？", scope: .public, isAnonymous: true, hugs: 31, createdAt: Date().addingTimeInterval(-10800)),
        .init(id: "4", content: "今天不对自己说任何负面的话。打卡第一天！", scope: .public, isAnonymous: true, hugs: 56, createdAt: Date().addingTimeInterval(-14400)),
    ]
}

enum CCPostScope: String, CaseIterable, Hashable { case `public` = "社区公开"; case comforters = "仅安慰者" }
