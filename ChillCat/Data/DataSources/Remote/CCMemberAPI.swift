//
//  CCMemberAPI.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCMemberAPI {
    case info
    case products
    case privileges
    case purchase(productId: String)
    case history
}

extension CCMemberAPI: CCAPIEndpoint {
    var baseURL: URL { CCAppEnvironment.current.baseURL }

    var path: String {
        switch self {
        case .info:              return "/api/v1/member/info"
        case .products:          return "/api/v1/member/products"
        case .privileges:        return "/api/v1/member/privileges"
        case .purchase:          return "/api/v1/member/purchase"
        case .history:           return "/api/v1/member/history"
        }
    }

    var method: CCHTTPMethod {
        switch self {
        case .info, .products, .privileges, .history: return .get
        case .purchase: return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .purchase(let productId):
            return ["product_id": productId]
        default:
            return nil
        }
    }
}
