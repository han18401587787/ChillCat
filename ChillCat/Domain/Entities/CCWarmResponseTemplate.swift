import Foundation

struct CCWarmResponseTemplate: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let emoji: String
    let category: String // empathy/encourage/hope

    static let presets: [CCWarmResponseTemplate] = [
        .init(id: "1", content: "我也经历过类似的感受…", emoji: "💚", category: "empathy"),
        .init(id: "2", content: "你并不孤单，我在这里", emoji: "🤝", category: "empathy"),
        .init(id: "3", content: "一切都会好起来的", emoji: "🌅", category: "hope"),
        .init(id: "4", content: "给你一个大大的拥抱", emoji: "🫂", category: "encourage"),
        .init(id: "5", content: "我理解你的感受", emoji: "💙", category: "empathy"),
        .init(id: "6", content: "勇敢说出来已经很棒了", emoji: "⭐", category: "encourage"),
    ]
}
