import Foundation

/// 同步数据到 Widget App Group
enum CCWidgetDataSync {
    private static let defaults = UserDefaults(suiteName: "group.app.xuanpeace")

    static func update(emotion: String, streak: Int, quote: String? = nil) {
        defaults?.set(emotion, forKey: "widget_emotion")
        defaults?.set(streak, forKey: "widget_streak")
        if let q = quote { defaults?.set(q, forKey: "widget_quote") }
        // Widget 在下一次 Timeline 刷新时自动读取（最多1小时）
    }
}
