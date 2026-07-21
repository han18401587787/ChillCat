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
        LogD("[GrowthArchive] loadData start", module: .network, category: "GrowthArchive")
        isLoading = true
        error = nil

        // Load achievements — start from predefined, then merge with API
        achievements = CCAchievementBadge.allBadges

        do {
            let serverBadges = try await CCXuanAPI.getAchievements()
            // Map server VOs to local badge definitions
            let mapped = serverBadges.compactMap { Self.mapAchievement($0) }
            achievements = mergeAchievements(local: CCAchievementBadge.allBadges, server: mapped)
            LogI("[GrowthArchive] loaded \(serverBadges.count) server achievements", module: .network, category: "GrowthArchive")
        } catch {
            // Keep predefined badges as placeholders; API unavailable
            LogW("[GrowthArchive] API failed, keeping default badges: \(error)", module: .network, category: "GrowthArchive")
        }

        // Load milestones
        do {
            let serverMilestones = try await CCXuanAPI.getMilestones()
            milestones = serverMilestones.map { Self.mapMilestone($0) }
            LogI("[GrowthArchive] loaded \(serverMilestones.count) server milestones", module: .network, category: "GrowthArchive")
        } catch {
            milestones = []
            LogW("[GrowthArchive] API failed, no milestones loaded: \(error)", module: .network, category: "GrowthArchive")
        }

        // Load stats
        do {
            let serverStats = try await CCXuanAPI.getGrowthStats()
            stats = Self.mapGrowthStats(serverStats)
            LogI("[GrowthArchive] loaded stats", module: .network, category: "GrowthArchive")
        } catch {
            stats = nil
            self.error = error
            LogW("[GrowthArchive] API failed: \(error)", module: .network, category: "GrowthArchive")
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
