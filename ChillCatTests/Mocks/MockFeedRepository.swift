import Foundation
@testable import ChillCat

final class MockFeedRepository: CCFeedRepositoryProtocol {
    var feedResult: Result<(items: [CCFeedItem], total: Int64, hasMore: Bool), Error> = .success(([], 0, false))
    var searchResult: Result<(items: [CCFeedItem], total: Int64, hasMore: Bool), Error> = .success(([], 0, false))

    func fetchFeeds(page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        switch feedResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        switch searchResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}
