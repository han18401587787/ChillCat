//
//  CCJournalViewModel.swift 
//  ChillCat - 情绪日记
//

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
final class CCJournalViewModel {
    var entries: [CCXuanAPI.JournalEntry] = []
    var isLoading = true
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedYear = Calendar.current.component(.year, from: Date())
    var error: Error?

    func loadJournal() async {
        LogD("[Journal] loadJournal start month=\(selectedYear)-\(selectedMonth)", module: .network, category: "Journal")
        isLoading = true
        error = nil
        let m = String(format: "%04d-%02d", selectedYear, selectedMonth)
        do {
            let page = try await CCXuanAPI.getJournal(month: m)
            entries = page.list ?? []
            LogI("[Journal] loadJournal done: \(page.list?.count ?? 0) entries, total=\(page.total ?? 0)", module: .network, category: "Journal")
        } catch {
            entries = []
            self.error = error
            LogW("[Journal] API failed: \(error)", module: .network, category: "Journal")
        }
        isLoading = false
    }

    func previousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }

    func nextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }
}
