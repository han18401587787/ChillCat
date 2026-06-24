//
//  CCBehavioralActivationViewModel.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 行为激活 ViewModel
//

import Foundation
import SwiftUI

// MARK: - Activity Type

enum CCActivityType: String, CaseIterable, Identifiable {
    case pleasure = "愉悦"
    case mastery = "成就"
    case social = "社交"
    case physical = "身体"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pleasure: return "heart.fill"
        case .mastery: return "star.fill"
        case .social: return "person.2.fill"
        case .physical: return "figure.walk"
        }
    }

    var color: Color {
        switch self {
        case .pleasure: return Color(hex: "E8B8C8")
        case .mastery: return Color(hex: "F5A623")
        case .social: return Color(hex: "4A90D9")
        case .physical: return Color(hex: "7ED3B2")
        }
    }
}

// MARK: - Activity Model

struct CCActivity: Identifiable, Hashable {
    let id: String
    var name: String
    var type: CCActivityType
    var expectedMoodBoost: Int  // 1-10
    var actualMoodBoost: Int?   // 1-10, filled after completion
    var scheduledTime: Date?
    var isCompleted: Bool
    var completedAt: Date?

    static func empty() -> CCActivity {
        CCActivity(
            id: UUID().uuidString,
            name: "",
            type: .pleasure,
            expectedMoodBoost: 5,
            scheduledTime: nil,
            isCompleted: false,
            completedAt: nil
        )
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class CCBehavioralActivationViewModel {
    // Activities
    var plannedActivities: [CCActivity] = []
    var completedActivities: [CCActivity] = []

    // New activity form
    var newActivityName: String = ""
    var newActivityType: CCActivityType = .pleasure
    var newExpectedMoodBoost: Double = 5
    var newScheduledTime: Date = Date()
    var showNewActivityForm: Bool = false

    // Rating after completion
    var ratingActivityId: String?
    var ratingValue: Double = 5
    var showRatingSheet: Bool = false

    // View mode
    var selectedViewMode: CCBAViewMode = .today

    // MARK: - Computed

    var todaysActivities: [CCActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return plannedActivities.filter { activity in
            guard let time = activity.scheduledTime else { return true }
            return calendar.isDate(time, inSameDayAs: today)
        }
    }

    var weeklyActivities: [(Date, [CCActivity])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [(Date, [CCActivity])] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayActivities = plannedActivities.filter { activity in
                guard let time = activity.scheduledTime else { return false }
                return calendar.isDate(time, inSameDayAs: dayStart)
            }
            result.append((dayStart, dayActivities))
        }
        return result
    }

    var completionRate: Double {
        guard !plannedActivities.isEmpty else { return 0 }
        return Double(completedActivities.count) / Double(plannedActivities.count)
    }

    var averageExpectedBoost: Double {
        guard !completedActivities.isEmpty else { return 0 }
        let total = completedActivities.compactMap { $0.expectedMoodBoost }.reduce(0, +)
        return Double(total) / Double(completedActivities.count)
    }

    var averageActualBoost: Double {
        let withActual = completedActivities.compactMap { $0.actualMoodBoost }
        guard !withActual.isEmpty else { return 0 }
        return Double(withActual.reduce(0, +)) / Double(withActual.count)
    }

    var moodBoostComparison: String {
        let diff = averageActualBoost - averageExpectedBoost
        if diff > 1 {
            return "活动带来的心情提升超出了你的预期！"
        } else if diff >= 0 {
            return "活动基本达到了预期的效果。"
        } else if diff > -2 {
            return "效果略低于预期，但行动本身就是一种胜利。"
        } else {
            return "尝试调整活动类型或时间，找到更适合你的方式。"
        }
    }

    var isEmpty: Bool {
        plannedActivities.isEmpty
    }

    // MARK: - Actions

    func addActivity() {
        guard !newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let activity = CCActivity(
            id: UUID().uuidString,
            name: newActivityName,
            type: newActivityType,
            expectedMoodBoost: Int(newExpectedMoodBoost),
            scheduledTime: newScheduledTime,
            isCompleted: false,
            completedAt: nil
        )

        plannedActivities.append(activity)
        resetNewActivityForm()
        showNewActivityForm = false
    }

    func toggleCompletion(_ activity: CCActivity) {
        guard let index = plannedActivities.firstIndex(where: { $0.id == activity.id }) else { return }

        if plannedActivities[index].isCompleted {
            // Un-complete
            plannedActivities[index].isCompleted = false
            plannedActivities[index].actualMoodBoost = nil
            plannedActivities[index].completedAt = nil
            completedActivities.removeAll { $0.id == activity.id }
        } else {
            // Mark complete and show rating
            plannedActivities[index].isCompleted = true
            plannedActivities[index].completedAt = Date()
            ratingActivityId = activity.id
            ratingValue = Double(activity.expectedMoodBoost)
            showRatingSheet = true
        }
    }

    func submitRating() {
        guard let activityId = ratingActivityId,
              let index = plannedActivities.firstIndex(where: { $0.id == activityId }) else { return }

        plannedActivities[index].actualMoodBoost = Int(ratingValue)
        completedActivities.append(plannedActivities[index])
        showRatingSheet = false
        ratingActivityId = nil

        // Record to API
        Task {
            try? await CCXuanAPI.recordToolUsage(
                toolType: "behavioral_activation",
                duration: 30,
                completed: true
            )
        }
    }

    func deleteActivity(_ activity: CCActivity) {
        plannedActivities.removeAll { $0.id == activity.id }
        completedActivities.removeAll { $0.id == activity.id }
    }

    private func resetNewActivityForm() {
        newActivityName = ""
        newActivityType = .pleasure
        newExpectedMoodBoost = 5
        newScheduledTime = Date()
    }
}

// MARK: - View Mode

enum CCBAViewMode: String, CaseIterable {
    case today = "今日计划"
    case weekly = "周视图"
    case stats = "心情对比"
}
