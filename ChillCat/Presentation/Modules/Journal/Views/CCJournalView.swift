import SwiftUI

struct CCJournalView: View {
    @State private var selectedMonth = 4
    @Environment(\.ccAppTheme) private var theme

    let entries: [CCJournalEntry] = CCJournalEntry.sampleEntries
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    let weekDays = ["一","二","三","四","五","六","日"]

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                HStack {
                    Button(action: { selectedMonth -= 1 }) { Image(systemName: "chevron.left") }
                    Spacer()
                    Text("2026年\(selectedMonth)月").font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: { selectedMonth += 1 }) { Image(systemName: "chevron.right") }
                }.padding(.horizontal)

                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        ForEach(weekDays, id: \.self) { day in
                            Text(day).font(.system(size: 12)).foregroundColor(theme.textMuted).frame(maxWidth: .infinity)
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(calendarDays, id: \.self) { day in
                            if day > 0 {
                                let entry = entries.first { $0.day == day }
                                VStack(spacing: 2) {
                                    Text("\(day)").font(.system(size: 13))
                                    if let e = entry {
                                        Image(systemName: e.emotion.iconName).font(.system(size: 12)).foregroundColor(e.emotion.color)
                                    }
                                }.frame(height: 40).frame(maxWidth: .infinity)
                                .background(entry != nil ? entry!.emotion.color.opacity(0.15) : Color.clear).cornerRadius(6)
                            } else { Color.clear.frame(height: 40) }
                        }
                    }
                }.padding().background(theme.cardBackground).cornerRadius(theme.radiusLG)

                HStack(spacing: theme.spacingMD) {
                    statCard(title: "本周", value: "2 次", bg: theme.softPurpleLight.opacity(0.25))
                    statCard(title: "本月", value: "14 个", bg: theme.primaryMuted.opacity(0.25))
                    statCard(title: "坚持", value: "5 天", bg: theme.softGreenLight.opacity(0.25))
                }

                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("所有情绪日记与打卡记录").font(.system(size: 16, weight: .semibold))
                    ForEach(entries) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: entry.emotion.iconName).font(.system(size: 24))
                                .foregroundColor(entry.emotion.color).frame(width: 44, height: 44)
                                .background(entry.emotion.color.opacity(0.1)).cornerRadius(theme.radiusSM)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(entry.emotion.rawValue).font(.system(size: 15, weight: .medium))
                                    if entry.hasDoodle { Text("有涂鸦").font(.system(size: 11)).foregroundColor(theme.softPink) }
                                }
                                Text(entry.note).font(.system(size: 13)).foregroundColor(theme.textSecondary).lineLimit(2)
                            }
                            Spacer()
                            Text(entry.dateStr).font(.system(size: 12)).foregroundColor(theme.textMuted)
                        }.padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
                    }
                }
            }.padding()
        }.background(theme.background).navigationTitle("情绪日记")
    }

    var calendarDays: [Int] {
        Array(-2...30).compactMap { $0 > 0 ? $0 : nil } + Array(repeating: -1, count: 2)
    }

    func statCard(title: String, value: String, bg: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(Color(hex: "5A7A8A"))
            Text(title).font(.system(size: 12)).foregroundColor(theme.textSecondary)
        }.frame(maxWidth: .infinity).padding(.vertical, 12).background(bg).cornerRadius(theme.radiusMD)
    }
}

struct CCJournalEntry: Identifiable {
    let id: String; let day: Int; let emotion: CCEmotion; let note: String
    let hasDoodle: Bool; let dateStr: String
    static let sampleEntries: [CCJournalEntry] = [
        .init(id: "1", day: 15, emotion: .tired, note: "开会又被说了", hasDoodle: false, dateStr: "4月15日 周二"),
        .init(id: "2", day: 19, emotion: .happy, note: "拿到了那个项目的正向反馈", hasDoodle: true, dateStr: "4月19日 周六"),
        .init(id: "3", day: 22, emotion: .calm, note: "周末去了公园，坐在草地上发呆", hasDoodle: false, dateStr: "4月22日 周二"),
    ]
}

extension CCEmotion {
    var color: Color {
        switch self {
        case .calm: return Color(hex: "66BB6A"); case .happy: return Color(hex: "C9A063")
        case .tired: return Color(hex: "7A9AAA"); case .anxious: return Color(hex: "D4C8E8")
        case .wronged: return Color(hex: "E8B8C8"); case .lonely: return Color(hex: "A8C9D7")
        case .irritable: return Color(hex: "E57373"); case .confused: return Color(hex: "D9C8E3")
        case .anger: return Color(hex: "8B6F47"); case .drained: return Color(hex: "AAAAAA")
        }
    }
}
