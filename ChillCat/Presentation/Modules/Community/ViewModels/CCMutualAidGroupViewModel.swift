import Foundation
import SwiftUI

@MainActor @Observable
final class CCMutualAidGroupViewModel {
    var groups: [CCMutualAidGroup] = []
    var myGroups: [CCMutualAidGroup] = []
    var selectedCategory: String?
    var isLoading = false
    var isJoining = false
    var errorMessage: String?

    var categories: [String] {
        ["全部", "情绪", "生活", "关系", "成长", "健康"]
    }

    var filteredGroups: [CCMutualAidGroup] {
        guard let category = selectedCategory, category != "全部" else {
            return groups
        }
        return groups.filter { $0.category == category }
    }

    func loadGroups() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let remote = try await CCXuanAPI.fetchMutualAidGroups()
            if !remote.isEmpty {
                groups = remote
                print("✅ [MutualAid] loadGroups: \(remote.count) from API")
            } else {
                groups = CCMutualAidGroup.presetGroups
                print("⚠️ [MutualAid] loadGroups: empty API, using presets")
            }
        } catch {
            groups = CCMutualAidGroup.presetGroups
            print("⚠️ [MutualAid] loadGroups fallback to presets: \(error)")
        }

        myGroups = groups.filter { $0.isJoined }
    }

    func selectCategory(_ category: String?) {
        selectedCategory = category
    }

    func joinGroup(id: Int64) async {
        guard !isJoining else { return }
        isJoining = true
        defer { isJoining = false }

        // Optimistic update
        if let idx = groups.firstIndex(where: { $0.id == id }) {
            groups[idx].isJoined = true
        }

        do {
            try await CCXuanAPI.joinMutualAidGroup(id: id)
            myGroups = groups.filter { $0.isJoined }
            print("✅ [MutualAid] joinGroup id=\(id)")
        } catch {
            // Revert on failure
            if let idx = groups.firstIndex(where: { $0.id == id }) {
                groups[idx].isJoined = false
            }
            errorMessage = "加入失败，请重试"
            print("❌ [MutualAid] joinGroup failed id=\(id): \(error)")
        }
    }

    func leaveGroup(id: Int64) async {
        guard !isJoining else { return }
        isJoining = true
        defer { isJoining = false }

        // Optimistic update
        if let idx = groups.firstIndex(where: { $0.id == id }) {
            groups[idx].isJoined = false
        }

        do {
            try await CCXuanAPI.leaveMutualAidGroup(id: id)
            myGroups = groups.filter { $0.isJoined }
            print("✅ [MutualAid] leaveGroup id=\(id)")
        } catch {
            // Revert on failure
            if let idx = groups.firstIndex(where: { $0.id == id }) {
                groups[idx].isJoined = true
            }
            errorMessage = "退出失败，请重试"
            print("❌ [MutualAid] leaveGroup failed id=\(id): \(error)")
        }
    }
}
