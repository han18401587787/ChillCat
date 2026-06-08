import SwiftUI

struct CCTrendsView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var selectedTab = 0

    let weekData: [(day: String, emotions: [CCEmotion], count: Int)] = [
        ("周一", [.anxious], 2), ("周二", [.tired], 1), ("周三", [.tired, .wronged], 3),
        ("周四", [.calm], 1), ("周五", [.happy], 2), ("周六", [.happy, .calm], 3), ("周日", [.calm], 1),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                // Tab切换
                Picker("", selection: $selectedTab) {
                    Text("本周").tag(0); Text("本月").tag(1); Text("成长").tag(2)
                }.pickerStyle(.segmented).padding(.horizontal)

                if selectedTab == 0 { weekView }
                else if selectedTab == 1 { monthView }
                else { growthView }
            }.padding()
        }
        .background(theme.background).navigationTitle("情绪趋势")
    }

    // MARK: - Week View
    var weekView: some View {
        VStack(spacing: theme.spacingLG) {
            // 条形图
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("本周情绪波动").font(.system(size: 16, weight: .semibold))
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(weekData, id: \.day) { day in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day.emotions.first?.color ?? Color(hex: "B8D4E3"))
                                .frame(width: 36, height: max(8, CGFloat(day.count) * 28))
                            Text(day.day).font(.system(size: 11)).foregroundColor(theme.textSecondary)
                        }
                    }
                }
                .frame(height: 120).padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
            }

            // 统计
            HStack(spacing: theme.spacingSM) {
                statBox(value: "14", label: "本周记录", color: theme.softPurpleLight)
                statBox(value: "2", label: "情绪波动", color: theme.primaryMuted)
                statBox(value: "5", label: "打卡天数", color: theme.softGreenLight)
            }

            // 分析卡片
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("绪安洞察").font(.system(size: 16, weight: .semibold))
                insightCard(text: "这周你有 3 天感到疲惫，记录了 5 次打卡。你已经很努力了。", color: Color(hex: "D4C8E8"))
                insightCard(text: "你通常在周三情绪最低，周末会好一些。或许可以在周三留点轻松的事情给自己？", color: Color(hex: "B8D4E3"))
            }
        }
    }

    // MARK: - Month View
    var monthView: some View {
        VStack(spacing: theme.spacingLG) {
            Text("本月情绪回顾").font(.system(size: 18, weight: .bold))
            HStack(spacing: theme.spacingSM) {
                statBox(value: "42", label: "打卡", color: theme.softPurpleLight)
                statBox(value: "8", label: "平静日", color: Color(hex: "66BB6A").opacity(0.25))
                statBox(value: "5", label: "疲惫日", color: theme.primaryMuted)
            }
            insightCard(text: "本月情绪总体平稳，相比上月疲惫天数减少了 2 天。继续保持！", color: Color(hex: "D5E8D4"))
        }
    }

    // MARK: - Growth View
    var growthView: some View {
        VStack(spacing: theme.spacingLG) {
            Text("成长轨迹").font(.system(size: 18, weight: .bold))
            VStack(spacing: theme.spacingSM) {
                growthRow(icon: "chart.line.uptrend.xyaxis", title: "焦虑天数下降 40%", subtitle: "相比上月")
                growthRow(icon: "figure.mind.and.body", title: "冥想完成 12 次", subtitle: "累计 48 分钟")
                growthRow(icon: "pencil.and.list.clipboard", title: "日记 28 篇", subtitle: "连续记录 5 天")
            }
            insightCard(text: "你已经连续打卡 5 天了！明天也要记得来绪安看看自己。", color: Color(hex: "E8D9F0"))
        }
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
