import Foundation
import SwiftUI

@MainActor @Observable
final class CCTreeHoleViewModel {
    var isAnonymous: Bool = true
    var posts: [CCTreeHolePost] = CCTreeHolePost.samplePosts
    var newPostText: String = ""
    var selectedScope: CCPostScope = .public

    func toggleAnonymous() { isAnonymous.toggle() }
    func publishPost() {
        guard !newPostText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let post = CCTreeHolePost(id: UUID().uuidString, content: newPostText, scope: selectedScope, isAnonymous: isAnonymous, hugs: 0, createdAt: Date())
        posts.insert(post, at: 0)
        newPostText = ""
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
        .init(id: "1", content: "下午开会的时候leader当着所有人说我的方案不够细致，我知道他说的有道理，但就是委屈…", scope: .public, isAnonymous: true, hugs: 12, createdAt: Date().addingTimeInterval(-3600)),
        .init(id: "2", content: "周末去了公园，坐在草地上发呆了一个小时，脑子难得空空的，感觉很舒服。", scope: .public, isAnonymous: true, hugs: 8, createdAt: Date().addingTimeInterval(-7200)),
        .init(id: "3", content: "为什么明明没做错，还是觉得对不起所有人？", scope: .public, isAnonymous: true, hugs: 23, createdAt: Date().addingTimeInterval(-10800)),
    ]
}

enum CCPostScope: String, CaseIterable, Hashable { case `public` = "社区公开"; case comforters = "仅安慰者" }
