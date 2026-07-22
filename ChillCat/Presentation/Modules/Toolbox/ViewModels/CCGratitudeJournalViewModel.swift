//
//  CCGratitudeJournalViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 感恩日记 ViewModel
//

import Foundation
import SwiftUI
import Combine

// MARK: - Gratitude Entry Model

struct CCGratitudeEntry: Identifiable, Hashable {
    let id: String
    var date: Date
    var things: [CCGoodThing]

    struct CCGoodThing: Identifiable, Hashable {
        let id: String
        var title: String
        var reason: String
        var emoji: String
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCGratitudeJournalViewModel {
    // Current entry
    var selectedDate: Date = Date()
    var thing1Title: String = ""
    var thing1Reason: String = ""
    var thing1Emoji: String = "😊"

    var thing2Title: String = ""
    var thing2Reason: String = ""
    var thing2Emoji: String = "😊"

    var thing3Title: String = ""
    var thing3Reason: String = ""
    var thing3Emoji: String = "😊"

    // Emoji picker
    var showEmojiPicker: Bool = false
    var activeEmojiSlot: Int = 0  // 1, 2, or 3

    // History
    var pastEntries: [CCGratitudeEntry] = []

    // State
    var isCompleted: Bool = false
    var showCompletionAnimation: Bool = false

    // MARK: - Computed

    var streakCount: Int {
        let calendar = Calendar.current
        let dates = Set(pastEntries.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Check if today has an entry or if we're counting from the current entry
        if !isTodayEntryComplete {
            // Count from yesterday
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        while dates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        return streak
    }

    var isTodayEntryComplete: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return pastEntries.contains { Calendar.current.startOfDay(for: $0.date) == today }
    }

    var canSubmit: Bool {
        !thing1Title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !thing2Title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !thing3Title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }

    var completionMessage: String {
        if streakCount >= 30 {
            return "你已经连续\(streakCount)天记录感恩！这是一个了不起的习惯。研究表明，持续感恩练习可以显著提升幸福感。"
        } else if streakCount >= 7 {
            return "连续\(streakCount)天了！感恩的种子正在你心中生根发芽。"
        } else if streakCount >= 1 {
            return "连续\(streakCount)天记录感恩。坚持下去，你会看到生活的更多美好。"
        } else {
            return "今天的三件好事已记录。每一天都有值得感恩的瞬间。"
        }
    }

    // MARK: - Actions

    func openEmojiPicker(for slot: Int) {
        activeEmojiSlot = slot
        showEmojiPicker = true
    }

    func selectEmoji(_ emoji: String) {
        switch activeEmojiSlot {
        case 1: thing1Emoji = emoji
        case 2: thing2Emoji = emoji
        case 3: thing3Emoji = emoji
        default: break
        }
        showEmojiPicker = false
    }

    func submitEntry() {
        guard canSubmit else { return }

        let entry = CCGratitudeEntry(
            id: UUID().uuidString,
            date: selectedDate,
            things: [
                .init(id: UUID().uuidString, title: thing1Title, reason: thing1Reason, emoji: thing1Emoji),
                .init(id: UUID().uuidString, title: thing2Title, reason: thing2Reason, emoji: thing2Emoji),
                .init(id: UUID().uuidString, title: thing3Title, reason: thing3Reason, emoji: thing3Emoji),
            ]
        )

        pastEntries.insert(entry, at: 0)
        isCompleted = true

        // Trigger completion animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            showCompletionAnimation = true
        }

        // Reset after delay
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation {
                showCompletionAnimation = false
                isCompleted = false
            }
        }

        // Record to API
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "gratitude_journal",
                duration: 60,
                completed: true
            )
        }

        resetCurrentEntry()
    }

    func resetCurrentEntry() {
        thing1Title = ""
        thing1Reason = ""
        thing1Emoji = "😊"
        thing2Title = ""
        thing2Reason = ""
        thing2Emoji = "😊"
        thing3Title = ""
        thing3Reason = ""
        thing3Emoji = "😊"
        selectedDate = Date()
    }

    // MARK: - Seed sample data

    func loadSampleData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        pastEntries = [
            CCGratitudeEntry(
                id: "sample1",
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                things: [
                    .init(id: "s1a", title: "阳光很好", reason: "早上出门时看到了美丽的日出", emoji: "☀️"),
                    .init(id: "s1b", title: "同事帮我带了咖啡", reason: "她知道我喜欢喝拿铁", emoji: "☕️"),
                    .init(id: "s1c", title: "晚饭很好吃", reason: "尝试了新菜谱，成功了", emoji: "🍝"),
                ]
            ),
            CCGratitudeEntry(
                id: "sample2",
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                things: [
                    .init(id: "s2a", title: "收到了朋友的消息", reason: "很久没联系的朋友突然发来问候", emoji: "💌"),
                    .init(id: "s2b", title: "健身坚持了", reason: "完成了今天的运动计划", emoji: "💪"),
                    .init(id: "s2c", title: "读了一本好书", reason: "书中的一句话给了我启发", emoji: "📖"),
                ]
            ),
            CCGratitudeEntry(
                id: "sample3",
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                things: [
                    .init(id: "s3a", title: "地铁上有人让座", reason: "陌生人给一位老人让了座，很暖心", emoji: "💺"),
                    .init(id: "s3b", title: "小猫蹭了我", reason: "小区里的流浪猫主动来蹭我的腿", emoji: "🐱"),
                    .init(id: "s3c", title: "工作有进展", reason: "卡了很久的问题终于解决了", emoji: "✅"),
                ]
            ),
        ]
    }
}
