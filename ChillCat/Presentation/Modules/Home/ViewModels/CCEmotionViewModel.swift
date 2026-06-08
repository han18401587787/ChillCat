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
    var streakDays: Int = 5
    var totalDays: Int = 23
    var weeklyEmotions: [(CCEmotion, Int)] = []
    var weeklyNote: String = ""
    var dailyTask: String = ""
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
        weeklyNote = "这周你有 3 天感到疲惫，记录了 5 次打卡。你已经很努力了。"
        dailyTask = "记录一件今天微小的开心事"
    }

    func selectEmotion(_ emotion: CCEmotion) {
        selectedEmotion = emotion
    }

    func completeCheckIn() {
        hasCheckedIn = true
    }

    func completeDailyTask() {
        dailyTaskCompleted = true
    }
}
