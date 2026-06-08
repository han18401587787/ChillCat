//
//  CCSearchViewModel.swift
//  ChillCat
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCSearchViewModel {
    var query = ""
    var results: [CCFeedItem] = []
    var isLoading = false
    var errorMessage: String?
    var hasSearched = false

    private let fetchFeedsUseCase: CCFetchFeedsUseCase

    init(fetchFeedsUseCase: CCFetchFeedsUseCase) {
        self.fetchFeedsUseCase = fetchFeedsUseCase
    }

    var isEmpty: Bool {
        hasSearched && !isLoading && results.isEmpty
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        hasSearched = true

        do {
            let result = try await fetchFeedsUseCase.search(query: trimmed, page: 1, pageSize: 20)
            results = result.items
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
