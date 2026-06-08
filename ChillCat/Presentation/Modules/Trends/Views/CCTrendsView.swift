import SwiftUI

struct CCTrendsView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var selectedTab = 0
    @State private var stats: CCXuanAPI.WeeklyStats?
    @State private var weekData: [(String, Int)] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                Picker("", selection: $selectedTab) {
                    Text("本周").tag(0); Text("本月").tag(1); Text("成长").tag(2)
                }.pickerStyle(.segmented).padding(.horizontal)

                if selectedTab == 0 { weekView }
                else if selectedTab == 1 { monthView }
                else { growthView }
            }.padding()
        }
        .background(theme.background).navigationTitle("情绪趋势")
        .task { await loadStats() }
    }

    // MARK: - Week View
    var weekView: some View {
        VStack(spacing: theme.spacingLG) {
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("本周情绪波动").font(.system(size: 16, weight: .semibold))
                if weekData.isEmpty {
                    CCSkeletonView().frame(height: 100).cornerRadius(theme.radiusMD)
                } else {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(weekData, id: \.0) { (day, count) in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: "B8D4E3")).frame(width: 36, height: max(8, CGFloat(count) * 24))
                                Text(day).font(.system(size: 11)).foregroundColor(theme.textSecondary)
                            }
                        }
                    }.frame(height: 120).padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
                }
            }

            HStack(spacing: theme.spacingSM) {
                statBox(value: "\(stats?.totalCount ?? 0)", label: "本周记录", color: theme.softPurpleLight)
                statBox(value: "\(stats?.streakDays ?? 0)", label: "连续天数", color: theme.primaryMuted)
                statBox(value: stats?.topEmotion ?? "—", label: "主要情绪", color: theme.softGreenLight)
            }

            if let s = stats, !s.insight.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("绪安洞察").font(.system(size: 16, weight: .semibold))
                    insightCard(text: s.insight, color: Color(hex: "D4C8E8"))
                }
            }
        }
    }

    var monthView: some View {
        VStack(spacing: theme.spacingLG) {
            Text("本月情绪回顾").font(.system(size: 18, weight: .bold))
            HStack(spacing: theme.spacingSM) {
                statBox(value: "\(stats?.totalCount ?? 0)", label: "打卡", color: theme.softPurpleLight)
                statBox(value: stats?.topEmotion ?? "—", label: "主要情绪", color: Color(hex: "66BB6A").opacity(0.25))
                statBox(value: "\(stats?.streakDays ?? 0)", label: "连续", color: theme.primaryMuted)
            }
        }
    }

    var growthView: some View {
        VStack(spacing: theme.spacingLG) {
            Text("成长轨迹").font(.system(size: 18, weight: .bold))
            VStack(spacing: theme.spacingSM) {
                growthRow(icon: "chart.line.uptrend.xyaxis", title: "本周记录 \(stats?.totalCount ?? 0) 次", subtitle: "继续坚持")
                growthRow(icon: "figure.mind.and.body", title: "连续打卡 \(stats?.streakDays ?? 0) 天", subtitle: "加油保持")
                growthRow(icon: "pencil.and.list.clipboard", title: "今日主要情绪", subtitle: stats?.topEmotion ?? "暂无数据")
            }
        }
    }

    private func loadStats() async {
        isLoading = true
        do {
            let s = try await CCXuanAPI.getWeeklyStats()
            stats = s
            let dayNames = ["日","一","二","三","四","五","六"]
            var counts: [String: Int] = [:]
            for e in s.entries {
                let d = e.checkinDate
                let idx = dayOfWeek(from: d)
                counts[dayNames[idx], default: 0] += 1
            }
            weekData = dayNames.map { ($0, counts[$0] ?? 0) }
        } catch {}
        isLoading = false
    }

    private func dayOfWeek(from dateStr: String) -> Int {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: dateStr) { return Calendar.current.component(.weekday, from: d) - 1 }
        return 0
    }

    // MARK: - Components
    func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold)).foregroundColor(Color(hex: "5A7A8A"))
            Text(label).font(.system(size: 12)).foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(color.opacity(0.3)).cornerRadius(theme.radiusMD)
    }

    func insightCard(text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles").foregroundColor(Color(hex: "C9A063"))
            Text(text).font(.system(size: 14)).foregroundColor(theme.textSecondary).lineSpacing(4)
            Spacer()
        }.padding().background(color.opacity(0.25)).cornerRadius(theme.radiusMD)
    }

    func growthRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(Color(hex: "5A7A8A")).frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(subtitle).font(.system(size: 12)).foregroundColor(theme.textSecondary)
            }
            Spacer()
        }.padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
    }
}
