//
//  CCMessageAPI.swift
//  ChillCat
//

import Foundation

enum CCMessageAPI {
    case list(page: Int, pageSize: Int)
    case unreadCount
    case markRead(id: String)
}

extension CCMessageAPI: CCAPIEndpoint {
    var baseURL: URL { CCAppEnvironment.current.baseURL }
    var path: String {
        switch self {
        case .list: return "/api/v1/messages"
        case .unreadCount: return "/api/v1/messages/unread"
        case .markRead(let id): return "/api/v1/messages/\(id)/read"
        }
    }
    var method: CCHTTPMethod {
        switch self {
        case .markRead: return .post
        default: return .get
        }
    }
    var queryItems: [URLQueryItem]? {
        if case .list(let p, let ps) = self {
            return [URLQueryItem(name: "page", value: String(p)), URLQueryItem(name: "page_size", value: String(ps))]
        }
        return nil
    }
    var body: Encodable? { nil }
}
