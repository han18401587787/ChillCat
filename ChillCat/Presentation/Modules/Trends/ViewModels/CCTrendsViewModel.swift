//
//  CCTrendsViewModel.swift
//  绪安
//

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
final class CCTrendsViewModel {
    var stats: CCXuanAPI.WeeklyStats?
    var weekData: [(String, Int)] = []
    var isLoading = true
    var errorMessage: String?

    func loadStats() async {
        LogD("[Trends] loadStats start", module: .network, category: "Trends")
        isLoading = true
        errorMessage = nil
        do {
            let s = try await CCXuanAPI.getWeeklyStats()
            stats = s
            let dayNames = ["日", "一", "二", "三", "四", "五", "六"]
            var counts: [String: Int] = [:]
            for e in s.entries ?? [] {
                guard let d = e.checkinDate else { continue }
                let idx = dayOfWeek(from: d)
                counts[dayNames[idx], default: 0] += 1
            }
            weekData = dayNames.map { ($0, counts[$0] ?? 0) }
            LogI("[Trends] loadStats done: \(s.totalCount) entries, top=\(s.topEmotion), streak=\(s.streakDays)", module: .network, category: "Trends")
        } catch {
            stats = nil
            weekData = []
            errorMessage = "数据加载失败，请检查网络后重试"
            LogW("[Trends] API failed: \(error)", module: .network, category: "Trends")
        }
        isLoading = false
    }

    func retry() async {
        await loadStats()
    }

    var isEmpty: Bool {
        guard let s = stats else { return true }
        return s.totalCount == 0
    }

    private func dayOfWeek(from dateStr: String) -> Int {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: dateStr) { return Calendar.current.component(.weekday, from: d) - 1 }
        return 0
    }
}
