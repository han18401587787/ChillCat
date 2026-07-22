//
//  CCEmotionCalendarView.swift
//  绪安 - 情绪日历 (严格对照设计稿 page_06 像素级还原)
//

import SwiftUI

struct CCEmotionCalendarView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let emotionColors: [String: Color] = [
        "平静": Color.xuanMint,
        "愉悦": Color.xuanApricot,
        "焦虑": Color(hex: "A085C6"),
        "低落": Color.xuanInfo,
        "愤怒": Color.xuanDanger,
        "疲惫": Color.xuanTextTertiary
    ]

    // 模拟数据
    private let emotionData: [String: (emoji: String, emotion: String)] = [
        "2026-06-01": ("😌", "平静"),
        "2026-06-02": ("😊", "愉悦"),
        "2026-06-03": ("😌", "平静"),
        "2026-06-04": ("😰", "焦虑"),
        "2026-06-05": ("😢", "低落"),
        "2026-06-08": ("😌", "平静"),
        "2026-06-09": ("😊", "愉悦"),
        "2026-06-10": ("😌", "平静"),
        "2026-06-12": ("😰", "焦虑"),
        "2026-06-15": ("😊", "愉悦"),
        "2026-06-16": ("😌", "平静"),
        "2026-06-17": ("😡", "愤怒"),
        "2026-06-18": ("😌", "平静"),
        "2026-06-19": ("😊", "愉悦"),
        "2026-06-20": ("😌", "平静"),
        "2026-06-22": ("😴", "疲惫"),
        "2026-06-23": ("😊", "愉悦"),
        "2026-06-24": ("😌", "平静"),
        "2026-06-25": ("😊", "愉悦"),
        "2026-06-26": ("😌", "平静"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 月份导航
                monthNavigator

                // 星期头
                weekdayHeader

                // 日历网格
                calendarGrid

                // 选中日期详情
                let dateStr = dateString(from: selectedDate)
                if let data = emotionData[dateStr] {
                    dayDetailCard(date: selectedDate, emoji: data.emoji, emotion: data.emotion)
                }

                // 月度统计
                monthlyStats
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪日历")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 月份导航
    private var monthNavigator: some View {
        HStack {
            Button(action: {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)! }
            }) {
                Image("common_back")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(width: 36, height: 36)
            }

            Spacer()

            Text(monthYearString(from: currentMonth))
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()

            Button(action: {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }
            }) {
                Image("common_more")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(width: 36, height: 36)
            }
        }
    }

    // MARK: - 星期头
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                Text(day)
                    .font(XuanFont.bodyS)
                    .foregroundColor(day == "六" || day == "日" ? Color.xuanPink : Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 日历网格
    private var calendarGrid: some View {
        let days = daysInMonth(currentMonth)
        let firstWeekday = firstWeekdayOfMonth(currentMonth)
        let totalCells = firstWeekday + days

        return VStack(spacing: XuanSpacing.xs) {
            ForEach(0..<6) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7) { col in
                        let index = row * 7 + col
                        if index >= firstWeekday && index < totalCells {
                            let day = index - firstWeekday + 1
                            let date = dateFor(day: day, month: currentMonth)
                            let dateStr = dateString(from: date)
                            let hasEmotion = emotionData[dateStr] != nil
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(date)

                            dayCell(day: day, hasEmotion: hasEmotion, isSelected: isSelected, isToday: isToday, date: date)
                        } else {
                            Color.clear.frame(maxWidth: .infinity).frame(height: 48)
                        }
                    }
                }
            }
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func dayCell(day: Int, hasEmotion: Bool, isSelected: Bool, isToday: Bool, date: Date) -> some View {
        Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(isToday ? XuanFont.bodyLBold : XuanFont.bodyM)
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? Color.xuanApricot :
                        Color.xuanTextPrimary
                    )

                if hasEmotion {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.6) : Color.xuanMint)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                isSelected
                    ? Color.xuanApricot
                    : (isToday ? Color.xuanApricot.opacity(0.08) : Color.clear)
            )
            .cornerRadius(XuanRadius.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 日详情卡片
    private func dayDetailCard(date: Date, emoji: String, emotion: String) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                Text(emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(emotion)
                        .font(XuanFont.h3)
                        .foregroundColor(emotionColors[emotion] ?? Color.xuanTextPrimary)
                    Text(dateDetailString(from: date))
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                Spacer()
            }

            // 模拟当日记录
            Text("今天工作虽然忙碌，但完成了重要项目的第一阶段。晚上和好友一起吃了个饭，聊了很多开心的事。感恩有这样的朋友在身边。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(5)
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 月度统计
    private var monthlyStats: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("\(monthYearString(from: currentMonth)) 统计")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            HStack(spacing: XuanSpacing.lg) {
                statBadge(value: "20", label: "记录天数", color: Color.xuanMint)
                statBadge(value: "5", label: "情绪种类", color: Color.xuanApricotDark)
                statBadge(value: "65%", label: "正向占比", color: Color.xuanPink)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: XuanSpacing.xs) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func dateDetailString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date)
    }

    private func daysInMonth(_ date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)!.count
    }

    private func firstWeekdayOfMonth(_ date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDay)
        return (weekday + 5) % 7 // 调整为周一=0
    }

    private func dateFor(day: Int, month: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        return calendar.date(from: components)!
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCEmotionCalendarView()
    }
}
