//
//  CCSettingsViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI
import Observation
import Combine

@MainActor
@Observable
final class CCSettingsViewModel {
    // MARK: - Notifications
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "cc_settings_notifications_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "cc_settings_notifications_enabled") }
    }

    // MARK: - Privacy toggles
    var showMood: Bool {
        get { UserDefaults.standard.object(forKey: "cc_privacy_show_mood") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "cc_privacy_show_mood") }
    }
    var showJournal: Bool {
        get { UserDefaults.standard.object(forKey: "cc_privacy_show_journal") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "cc_privacy_show_journal") }
    }
    var allowDataCollection: Bool {
        get { UserDefaults.standard.object(forKey: "cc_privacy_allow_data_collection") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "cc_privacy_allow_data_collection") }
    }

    // MARK: - Data metrics
    var moodDiaryCount = "—"
    var moodDiarySize = "—"
    var voiceMemoCount = "—"
    var voiceMemoSize = "—"
    var treeHoleCount = "—"
    var treeHoleSize = "—"
    var isLoadingMetrics = false

    // MARK: - Feedback
    var feedbackType = "建议"
    var feedbackContent = ""
    var feedbackContact = ""
    var isSubmitting = false
    var submitted = false
    var errorMessage: String?

    // MARK: - Data management actions
    var showDeleteConfirmation = false
    var pendingDeleteTarget: String?

    func loadDataMetrics() async {
        isLoadingMetrics = true
        // Stub: wire to real data store queries in production
        try? await Task.sleep(nanoseconds: 300_000_000)
        moodDiaryCount = "28 条记录"
        moodDiarySize = "约 2.3 MB"
        voiceMemoCount = "3 条记录"
        voiceMemoSize = "约 4.1 MB"
        treeHoleCount = "12 条记录"
        treeHoleSize = "约 0.5 MB"
        isLoadingMetrics = false
    }

    func exportMoodDiary() {
        // Stub: wire to data export service
    }

    func exportVoiceMemo() {
        // Stub: wire to data export service
    }

    func exportTreeHolePosts() {
        // Stub: wire to data export service
    }

    func clearCache() {
        Task { await CCCacheManager().clear() }
    }

    func exportAllData() {
        // Stub: wire to data export service
    }

    func deleteAllMoodDiary() {
        // Stub: wire to diary deletion service
    }

    func deleteAllTreeHolePosts() {
        // Stub: wire to tree hole deletion service
    }

    func initiateRealNameFlow() {
        // Stub: navigate to real-name verification flow
    }

    func submitFeedback() async {
        guard !feedbackContent.isEmpty else { return }
        isSubmitting = true
        errorMessage = nil
        do {
            // Stub: wire to feedback API endpoint
            try await Task.sleep(nanoseconds: 800_000_000)
            submitted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
