//
//  CCGrowthArchiveViewModel.swift
//  ChillCat
//
//  成长档案 — ViewModel
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCGrowthArchiveViewModel {

    // MARK: - Published State

    var achievements: [CCAchievementBadge] = []
    var milestones: [CCMilestone] = []
    var stats: CCGrowthStats?
    var selectedPeriod: String = "month"
    var categoryFilter: CCAchievementBadge.CCBadgeCategory?
    var isLoading = false
    var error: Error?

    // MARK: - Computed

    var filteredAchievements: [CCAchievementBadge] {
        guard let filter = categoryFilter else { return achievements }
        return achievements.filter { $0.category == filter }
    }

    var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    var totalCount: Int {
        achievements.count
    }

    var periodMilestones: [CCMilestone] {
        let cutoff: Date
        let calendar = Calendar.current
        switch selectedPeriod {
        case "week":
            cutoff = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case "quarter":
            cutoff = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        default: // month
            cutoff = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        }
        return milestones.filter { $0.date >= cutoff }
    }

    var periodInsights: [String] {
        stats?.aiInsights ?? []
    }

    // MARK: - Load

    func loadData() async {
        print("🔄 [GrowthArchive] loadData start")
        isLoading = true
        error = nil

        // Load achievements — start from predefined, then merge with API
        achievements = CCAchievementBadge.allBadges

        do {
            let serverBadges = try await CCXuanAPI.getAchievements()
            // Map server VOs to local badge definitions
            let mapped = serverBadges.compactMap { Self.mapAchievement($0) }
            achievements = mergeAchievements(local: CCAchievementBadge.allBadges, server: mapped)
            print("✅ [GrowthArchive] loaded \(serverBadges.count) server achievements")
        } catch {
            // Use mock data when API is unavailable
            achievements = generateMockAchievementProgress()
            print("⚠️ [GrowthArchive] API failed, using mock achievements: \(error)")
        }

        // Load milestones
        do {
            let serverMilestones = try await CCXuanAPI.getMilestones()
            if serverMilestones.isEmpty {
                milestones = CCMilestone.mockMilestones
            } else {
                milestones = serverMilestones.map { Self.mapMilestone($0) }
            }
            print("✅ [GrowthArchive] loaded \(serverMilestones.count) server milestones")
        } catch {
            milestones = CCMilestone.mockMilestones
            print("⚠️ [GrowthArchive] API failed, using mock milestones: \(error)")
        }

        // Load stats
        do {
            let serverStats = try await CCXuanAPI.getGrowthStats()
            stats = Self.mapGrowthStats(serverStats)
            print("✅ [GrowthArchive] loaded stats")
        } catch {
            stats = CCGrowthStats.mock
            print("⚠️ [GrowthArchive] API failed, using mock stats: \(error)")
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func mergeAchievements(
        local: [CCAchievementBadge],
        server: [CCAchievementBadge]
    ) -> [CCAchievementBadge] {
        var merged = local
        for s in server {
            if let idx = merged.firstIndex(where: { $0.id == s.id }) {
                merged[idx].isUnlocked = s.isUnlocked
                merged[idx].unlockedAt = s.unlockedAt
                merged[idx].progress = s.progress
            }
        }
        return merged
    }

    private func generateMockAchievementProgress() -> [CCAchievementBadge] {
        var badges = CCAchievementBadge.allBadges
        let unlockedIDs: Set<String> = [
            "first_checkin", "streak_7", "emotions_5", "tools_3",
            "posts_1", "safety_plan", "values_done", "meditation_10",
        ]
        let progressMap: [String: Int] = [
            "streak_30": 18, "checkin_100": 32, "emotions_10": 7,
            "tools_5": 4, "tools_all": 5, "posts_10": 3,
            "hugs_50": 23, "journal_30": 18, "gratitude_21": 12,
            "cbt_5": 3, "body_scan_10": 6, "activation_7": 4,
        ]
        for i in badges.indices {
            if unlockedIDs.contains(badges[i].id) {
                badges[i].isUnlocked = true
                badges[i].progress = badges[i].targetValue
                badges[i].unlockedAt = Date().addingTimeInterval(-86400 * Double.random(in: 1...30))
            } else if let prog = progressMap[badges[i].id] {
                badges[i].progress = prog
            }
        }
        return badges
    }
}

// MARK: - CCXuanAPI Bridge Helpers

private extension CCGrowthArchiveViewModel {

    /// Map server AchievementVO → local CCAchievementBadge
    static func mapAchievement(_ vo: CCXuanAPI.AchievementVO) -> CCAchievementBadge? {
        guard let badge = CCAchievementBadge.allBadges.first(where: { $0.id == vo.code }) else { return nil }
        var result = badge
        result.isUnlocked = vo.isUnlocked
        result.progress = vo.progress
        if let unlockedAt = vo.unlockedAt {
            let formatter = ISO8601DateFormatter()
            result.unlockedAt = formatter.date(from: unlockedAt)
        }
        return result
    }

    /// Map server MilestoneVO → local CCMilestone
    static func mapMilestone(_ vo: CCXuanAPI.MilestoneVO) -> CCMilestone {
        let formatter = ISO8601DateFormatter()
        return CCMilestone(
            id: String(vo.id),
            title: vo.title,
            description: vo.description,
            date: formatter.date(from: vo.createdAt) ?? Date(),
            type: CCMilestoneType(rawValue: vo.milestoneType) ?? .personal
        )
    }

    /// Map server GrowthStatsVO → local CCGrowthStats
    static func mapGrowthStats(_ vo: CCXuanAPI.GrowthStatsVO) -> CCGrowthStats {
        return CCGrowthStats(
            totalCheckins: Int(vo.totalCheckins),
            emotionTypes: Int(vo.emotionTypes),
            toolsUsed: Int(vo.toolUsageCount),
            communityInteractions: Int(vo.communityInteractions),
            streakDays: Int(vo.streakDays),
            totalDiaryEntries: 0,
            totalMeditationMinutes: 0,
            aiInsights: [],
            topEmotions: [],
            toolUsage: [],
            growthKeywords: []
        )
    }
}
