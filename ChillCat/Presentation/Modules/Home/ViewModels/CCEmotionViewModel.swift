//
//  CCEmotionViewModel.swift
//  绪安
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCEmotionViewModel {
    var selectedEmotion: CCEmotion?
    var todayNote: String = ""
    var hasCheckedIn: Bool = false
    var streakDays: Int = 0
    var totalDays: Int = 0
    var isLoading = false
    var weeklyNote: String = "加载中..."
    var dailyTask: String = "记录一件今天微小的开心事"
    var dailyTaskCompleted: Bool = false
    var quote: String = ""

    private let quotes = [
        "允许自己偶尔脆弱，不是软弱，是给自己喘息的机会。",
        "没有人规定你一定要在某个年纪做到某件事。慢一点，也是在前进。",
        "没有人规定花朵一定要在春天盛开。",
        "今天不对自己说任何负面的话",
    ]

    init() {
        quote = quotes.randomElement() ?? quotes[0]
    }

    /// 由 View.task 调用，避免阻塞 init
    func loadData() async {
        await loadToday()
    }

    func loadToday() async {
        do {
            let today = try await CCXuanAPI.getToday()
            if today.id > 0 {
                hasCheckedIn = true
                if let e = CCEmotion.allCases.first(where: { $0.rawValue == today.emotion }) {
                    selectedEmotion = e
                }
                todayNote = today.note
            }
            streakDays = Int(today.streakDays)
            totalDays = Int(today.streakDays)
        } catch { weeklyNote = "这周你记录了 5 次打卡。你已经很努力了。" }
        await loadWeeklyStats()
    }

    private func loadWeeklyStats() async {
        do {
            let stats = try await CCXuanAPI.getWeeklyStats()
            weeklyNote = "本周记录 \(stats.totalCount) 次，你的情绪以「\(stats.topEmotion)」为主"
        } catch {
            weeklyNote = "开始记录你的第一份情绪吧"
        }
    }

    func selectEmotion(_ emotion: CCEmotion) {
        selectedEmotion = emotion
    }

    func completeCheckIn() {
        guard let emotion = selectedEmotion else { return }
        hasCheckedIn = true
        Task {
            do {
                let result = try await CCXuanAPI.checkin(emotion: emotion.rawValue, note: todayNote)
                streakDays = Int(result.streakDays)
                // 同步数据到 Widget
                CCWidgetDataSync.update(emotion: emotion.rawValue, streak: Int(result.streakDays), quote: quote)
            } catch {
                // Already checked in today — still show success
            }
        }
    }

    func completeDailyTask() {
        dailyTaskCompleted = true
    }
}
