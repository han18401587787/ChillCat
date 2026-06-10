import SwiftUI

struct CCJournalView: View {
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var entries: [CCXuanAPI.JournalEntry] = []
    @State private var isLoading = true
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

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
                            let hasEntry = dayHasEntry(day)
                            VStack(spacing: 2) {
                                Text("\(day)").font(.system(size: 13))
                                if hasEntry {
                                    Circle().fill(Color(hex: "5A7A8A")).frame(width: 4, height: 4)
                                }
                            }.frame(height: 40).frame(maxWidth: .infinity)
                            .background(hasEntry ? Color(hex: "5A7A8A").opacity(0.1) : Color.clear).cornerRadius(6)
                        }
                    }
                }.padding().background(theme.cardBackground).cornerRadius(theme.radiusLG)

                HStack(spacing: theme.spacingMD) {
                    statCard(title: "本月", value: "\(entries.count) 次", bg: theme.softPurpleLight.opacity(0.25))
                    statCard(title: "记录", value: "\(entries.count) 天", bg: theme.primaryMuted.opacity(0.25))
                    statCard(title: "坚持", value: "\(uniqueDays) 天", bg: theme.softGreenLight.opacity(0.25))
                }

                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("所有情绪日记与打卡记录").font(.system(size: 16, weight: .semibold))
                    if isLoading {
                        CCSkeletonList(count: 4)
                    } else if entries.isEmpty {
                        CCEmptyStateView(title: "暂无记录", message: "开始记录你的第一份情绪日记吧", actionTitle: nil, action: nil)
                    } else {
                        ForEach(entries) { entry in
                            HStack(spacing: 12) {
                                Image(systemName: CCEmotion.allCases.first(where: { $0.rawValue == entry.emotion })?.iconName ?? "circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(emotionColor(entry.emotion))
                                    .frame(width: 44, height: 44)
                                    .background(emotionColor(entry.emotion).opacity(0.1)).cornerRadius(theme.radiusSM)
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(entry.emotion).font(.system(size: 15, weight: .medium))
                                        if entry.hasDoodle { Text("有涂鸦").font(.system(size: 11)).foregroundColor(theme.softPink) }
                                    }
                                    if !entry.note.isEmpty {
                                        Text(entry.note).font(.system(size: 13)).foregroundColor(theme.textSecondary).lineLimit(2)
                                    }
                                }
                                Spacer()
                                Text(String(entry.checkinDate.suffix(5))).font(.system(size: 12)).foregroundColor(theme.textMuted)
                            }.padding().background(theme.cardBackground).cornerRadius(theme.radiusMD).onTapGesture { coordinator.navigate(to: .journalDetail(entry)) }
                        }
                    }
                }
            }.padding()
        }.background(theme.background).navigationTitle("情绪日记")
        .refreshable { isLoading = true; await loadJournal() }
        .task { await loadJournal() }
    }

    private var calendarDays: [Int] { (1...31).map { $0 } }
    private var uniqueDays: Int { Set(entries.map { $0.checkinDate }).count }

    private func loadJournal() async {
        isLoading = true
        let m = String(format: "%04d-%02d", Calendar.current.component(.year, from: Date()), selectedMonth)
        do {
            let page = try await CCXuanAPI.getJournal(month: m)
            entries = page.list
        } catch {}
        isLoading = false
    }

    private func dayHasEntry(_ day: Int) -> Bool {
        let dayStr = String(format: "%04d-%02d-%02d", Calendar.current.component(.year, from: Date()), selectedMonth, day)
        return entries.contains { $0.checkinDate == dayStr }
    }

    private func emotionColor(_ name: String) -> Color {
        let map: [String: String] = ["平静": "66BB6A","开心": "C9A063","疲惫": "7A9AAA","焦虑": "D4C8E8","委屈": "E8B8C8","孤独": "A8C9D7","烦躁": "E57373","迷茫": "D9C8E3","易怒": "8B6F47","内耗": "AAAAAA"]
        return Color(hex: map[name] ?? "B8D4E3")
    }

    func statCard(title: String, value: String, bg: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(Color(hex: "5A7A8A"))
            Text(title).font(.system(size: 12)).foregroundColor(theme.textSecondary)
        }.frame(maxWidth: .infinity).padding(.vertical, 12).background(bg).cornerRadius(theme.radiusMD)
    }
}
