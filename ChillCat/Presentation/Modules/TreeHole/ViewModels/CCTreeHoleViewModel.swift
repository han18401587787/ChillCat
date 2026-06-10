import Foundation
import SwiftUI

@MainActor @Observable
final class CCTreeHoleViewModel {
    var isAnonymous: Bool = true
    var posts: [CCResonancePost] = []
    var newPostText: String = ""
    var selectedScope: CCPostScope = .public
    var isLoading = false
    var isRefreshing = false
    var isLoadingMore = false
    var hasMore = true
    var onlineCount: Int64 = 0
    var errorMessage: String?
    private var currentPage = 1

    init() {}

    func loadPosts() async {
        print("🔄 [TreeHole] loadPosts start")
        isLoading = true; currentPage = 1
        do {
            let page = try await CCXuanAPI.listPosts(page: 1)
            posts = mapPosts(page.list)
            hasMore = page.total > posts.count
            print("✅ [TreeHole] loadPosts done: \(posts.count) posts, \(onlineCount) online")
        } catch {
            errorMessage = "加载失败，请重试"
            print("❌ [TreeHole] loadPosts failed: \(error)")
        }
        isLoading = false
    }

    func refresh() async {
        print("🔄 [TreeHole] refresh start")
        isRefreshing = true; currentPage = 1
        do {
            let page = try await CCXuanAPI.listPosts(page: 1)
            posts = mapPosts(page.list)
            hasMore = page.total > posts.count
            print("✅ [TreeHole] refresh done: \(posts.count) posts")
        } catch {
            errorMessage = "刷新失败，请重试"
            print("❌ [TreeHole] refresh failed: \(error)")
        }
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        print("🔄 [TreeHole] loadMore start page=\(currentPage + 1)")
        isLoadingMore = true; currentPage += 1
        do {
            let page = try await CCXuanAPI.listPosts(page: currentPage)
            posts += mapPosts(page.list)
            hasMore = page.total > posts.count
            print("✅ [TreeHole] loadMore done: +\(page.list.count) posts, total=\(posts.count)")
        } catch {
            currentPage -= 1
            errorMessage = "加载更多失败，请重试"
            print("❌ [TreeHole] loadMore failed: \(error)")
        }
        isLoadingMore = false
    }

    private func mapPosts(_ list: [CCXuanAPI.PostResponse]) -> [CCResonancePost] {
        list.map { p in
            CCResonancePost(
                id: String(p.id), content: p.content,
                emotion: "", emotionColor: "primaryMuted",
                resonanceCount: Int(p.hugs),
                isAnonymous: p.isAnonymous, displayName: p.displayName,
                createdAt: ISO8601DateFormatter().date(from: p.createdAt) ?? Date()
            )
        }
    }

    func toggleAnonymous() { isAnonymous.toggle() }

    func publishPost() {
        guard !newPostText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let text = newPostText; newPostText = ""
        let scope = selectedScope; let anon = isAnonymous
        Task {
            do {
                let _ = try await CCXuanAPI.createPost(content: text, scope: scope == .public ? "public" : "comforters", isAnonymous: anon)
                print("✅ [TreeHole] publishPost done")
                await loadPosts()
            } catch {
                newPostText = text
                errorMessage = "发布失败，请重试"
                print("❌ [TreeHole] publishPost failed: \(error)")
            }
        }
    }

    func resonatePost(_ post: CCResonancePost, encouragement: String? = nil) {
        guard let id = Int64(post.id) else { return }
        Task {
            do {
                try await CCXuanAPI.hugResonance(id: id, message: encouragement)
                if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[idx].resonanceCount += 1
                    posts[idx].hasResonated = true
                }
                print("✅ [TreeHole] resonatePost done id=\(id)")
            } catch {
                errorMessage = "共鸣失败，请重试"
                print("❌ [TreeHole] resonatePost failed id=\(id): \(error)")
            }
        }
    }
}

struct CCResonancePost: Identifiable, Hashable {
    let id: String; let content: String; let emotion: String
    let emotionColor: String; var resonanceCount: Int
    let isAnonymous: Bool; let displayName: String; let createdAt: Date
    var hasResonated: Bool = false

    var emotionIcon: String {
        switch emotion {
        case "焦虑": return "tornado"
        case "委屈": return "drop.fill"
        case "孤独": return "cloud.fill"
        case "烦躁": return "flame.fill"
        case "迷茫": return "questionmark.circle.fill"
        case "易怒": return "burst.fill"
        case "内耗": return "battery.25percent"
        case "平静": return "leaf.fill"
        case "开心": return "sun.max.fill"
        case "疲惫": return "moon.zzz.fill"
        default: return "circle.fill"
        }
    }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }; if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }; return "\(Int(d/86400))天前"
    }

    var formattedResonance: String {
        if resonanceCount >= 10000 { return String(format: "%.1f万", Double(resonanceCount) / 10000.0) }
        else if resonanceCount >= 1000 { return String(format: "%.1fk", Double(resonanceCount) / 1000.0) }
        else { return "\(resonanceCount)" }
    }

    static let samplePosts: [CCResonancePost] = [
        .init(id: "1", content: "三十岁生日一个人过的，给自己买了个小蛋糕。有点孤独，但也挺自由的。", emotion: "孤独", emotionColor: "primaryLight", resonanceCount: 2341, isAnonymous: true, displayName: "匿名用户", createdAt: Date().addingTimeInterval(-7200)),
        .init(id: "2", content: "下周一就答辩了，PPT改了八遍了还是不满意。", emotion: "焦虑", emotionColor: "softPurple", resonanceCount: 892, isAnonymous: true, displayName: "匿名用户", createdAt: Date().addingTimeInterval(-18000)),
        .init(id: "3", content: "今天不对自己说任何负面的话。打卡第一天！", emotion: "开心", emotionColor: "warmLight", resonanceCount: 1456, isAnonymous: true, displayName: "匿名用户", createdAt: Date().addingTimeInterval(-3600)),
        .init(id: "4", content: "下午开会的时候leader当着所有人说我的方案不够细致，我知道他说的有道理，但就是委屈…", emotion: "委屈", emotionColor: "softPink", resonanceCount: 489, isAnonymous: true, displayName: "匿名用户", createdAt: Date().addingTimeInterval(-14400)),
    ]
}

extension Notification.Name {
    static let treeHoleDidUpdate = Notification.Name("TreeHoleDidUpdate")
}

typealias CCTreeHolePost = CCResonancePost

enum CCPostScope: String, CaseIterable, Hashable { case `public` = "社区公开"; case comforters = "仅安慰者" }
