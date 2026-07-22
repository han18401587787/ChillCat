import Foundation
import SwiftUI
import Combine

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
                LogI("[MutualAid] loadGroups: \(remote.count) from API", module: .network, category: "MutualAid")
            } else {
                groups = CCMutualAidGroup.presetGroups
                LogW("[MutualAid] loadGroups: empty API, using presets", module: .network, category: "MutualAid")
            }
        } catch {
            groups = CCMutualAidGroup.presetGroups
            LogW("[MutualAid] loadGroups fallback to presets: \(error)", module: .network, category: "MutualAid")
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
            LogI("[MutualAid] joinGroup id=\(id)", module: .network, category: "MutualAid")
        } catch {
            // Revert on failure
            if let idx = groups.firstIndex(where: { $0.id == id }) {
                groups[idx].isJoined = false
            }
            errorMessage = "加入失败，请重试"
            LogE("[MutualAid] joinGroup failed id=\(id): \(error)", module: .network, category: "MutualAid")
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
            LogI("[MutualAid] leaveGroup id=\(id)", module: .network, category: "MutualAid")
        } catch {
            // Revert on failure
            if let idx = groups.firstIndex(where: { $0.id == id }) {
                groups[idx].isJoined = true
            }
            errorMessage = "退出失败，请重试"
            LogE("[MutualAid] leaveGroup failed id=\(id): \(error)", module: .network, category: "MutualAid")
        }
    }
}
