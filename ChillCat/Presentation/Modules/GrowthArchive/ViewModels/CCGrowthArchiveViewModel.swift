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
            // Merge server progress into local badge definitions
            achievements = mergeAchievements(local: CCAchievementBadge.allBadges, server: serverBadges)
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
                milestones = serverMilestones
            }
            print("✅ [GrowthArchive] loaded \(serverMilestones.count) server milestones")
        } catch {
            milestones = CCMilestone.mockMilestones
            print("⚠️ [GrowthArchive] API failed, using mock milestones: \(error)")
        }

        // Load stats
        do {
            stats = try await CCXuanAPI.getGrowthStats()
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

// MARK: - API Extensions (to be added to CCXuanAPI)

extension CCXuanAPI {

    /// 获取用户成就徽章列表
    static func getAchievements() async throws -> [CCAchievementBadge] {
        try await get("/api/v1/growth/achievements")
    }

    /// 获取用户里程碑列表
    static func getMilestones() async throws -> [CCMilestone] {
        try await get("/api/v1/growth/milestones")
    }

    /// 获取成长统计数据
    static func getGrowthStats() async throws -> CCGrowthStats {
        try await get("/api/v1/growth/stats")
    }
}
