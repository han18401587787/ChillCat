import WidgetKit
import SwiftUI

struct XuanEntry: TimelineEntry {
    let date: Date; let todayEmotion: String; let todayEmotionIcon: String
    let streakDays: Int; let quote: String
}

struct XuanProvider: TimelineProvider {
    func placeholder(in context: Context) -> XuanEntry {
        XuanEntry(date: Date(), todayEmotion: "平静", todayEmotionIcon: "emotion_calm", streakDays: 5, quote: "允许自己偶尔脆弱")
    }
    func getSnapshot(in context: Context, completion: @escaping (XuanEntry) -> Void) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<XuanEntry>) -> Void) {
        let data = loadFromAppGroup()
        let entry = XuanEntry(date: Date(), todayEmotion: data.emotion, todayEmotionIcon: data.icon, streakDays: data.streak, quote: data.quote)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
    private func loadFromAppGroup() -> (emotion: String, icon: String, streak: Int, quote: String) {
        let d = UserDefaults(suiteName: "group.app.xuanpeace")
        let emotion = d?.string(forKey: "widget_emotion") ?? "平静"
        let streak = d?.integer(forKey: "widget_streak") ?? 0
        let quote = d?.string(forKey: "widget_quote") ?? "温柔自愈  自在松弛"
        let icons: [String: String] = ["平静":"emotion_calm","开心":"emotion_happy","疲惫":"emotion_tired","焦虑":"emotion_anxious","委屈":"emotion_sad","孤独":"emotion_sad","烦躁":"emotion_angry","迷茫":"other_map","易怒":"emotion_angry","内耗":"emotion_tired"]
        return (emotion, icons[emotion] ?? "circle.fill", streak, quote)
    }
}

struct XuanWidgetEntryView: View {
    var entry: XuanEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall: smallWidget
        default: mediumWidget
        }
    }

    var smallWidget: some View {
        VStack(spacing: 6) {
            Image(entry.todayEmotionIcon).font(.system(size: 32)).foregroundColor(Color("XuanPrimary"))
            Text(entry.todayEmotion).font(.system(size: 13, weight: .medium))
            Text("连续\(entry.streakDays)天").font(.system(size: 22, weight: .bold)).foregroundColor(Color("XuanPrimary"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [Color("XuanBg1"), Color("XuanBg2")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(entry.todayEmotionIcon).font(.system(size: 36)).foregroundColor(Color("XuanPrimary"))
                Text(entry.todayEmotion).font(.system(size: 13, weight: .medium))
                Text("连续\(entry.streakDays)天").font(.system(size: 22, weight: .bold)).foregroundColor(Color("XuanPrimary"))
            }
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text("每日一语").font(.system(size: 11)).foregroundColor(.secondary)
                Text(entry.quote).font(.system(size: 14)).lineSpacing(4)
            }
        }
        .padding()
        .background(LinearGradient(colors: [Color("XuanBg1"), Color("XuanBg2")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct XuanWidget: Widget {
    let kind = "XuanWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: XuanProvider()) { entry in
            XuanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("绪安")
        .description("今日情绪和连续打卡天数")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
