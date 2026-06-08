//
//  CCHomeViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCHomeViewModel {
    var items: [CCFeedItem] = []
    var isLoading = false
    var isRefreshing = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMore = true

    private let fetchFeedsUseCase: CCFetchFeedsUseCase
    private var currentPage = 1
    private let pageSize = 10

    init(fetchFeedsUseCase: CCFetchFeedsUseCase) {
        self.fetchFeedsUseCase = fetchFeedsUseCase
    }

    func loadItems() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let result = try await fetchFeedsUseCase.execute(page: currentPage, pageSize: pageSize)
            items = result.items
            hasMore = result.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        isRefreshing = true
        currentPage = 1

        do {
            let result = try await fetchFeedsUseCase.execute(page: currentPage, pageSize: pageSize)
            items = result.items
            hasMore = result.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }

        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let result = try await fetchFeedsUseCase.execute(page: currentPage, pageSize: pageSize)
            items += result.items
            hasMore = result.hasMore
        } catch {
            // silently fail on pagination errors
        }

        isLoadingMore = false
    }
}
