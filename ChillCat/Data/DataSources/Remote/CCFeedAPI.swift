//
//  CCFeedAPI.swift
//  ChillCat
//

import Foundation

enum CCFeedAPI {
    case list(page: Int, pageSize: Int)
    case detail(id: String)
    case search(query: String, page: Int, pageSize: Int)
}

extension CCFeedAPI: CCAPIEndpoint {
    var baseURL: URL { CCAppEnvironment.current.baseURL }

    var path: String {
        switch self {
        case .list: return "/api/v1/feeds"
        case .detail(let id): return "/api/v1/feeds/\(id)"
        case .search: return "/api/v1/search"
        }
    }

    var method: CCHTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(let query, let page, let pageSize):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "page_size", value: String(pageSize))
            ]
        case .list(let page, let pageSize):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "page_size", value: String(pageSize))
            ]
        default: return nil
        }
    }

    var body: Encodable? { nil }
}
