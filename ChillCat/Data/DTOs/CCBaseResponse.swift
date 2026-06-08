//
//  CCBaseResponse.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCAPIResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?

    var isSuccess: Bool { code == 0 }
}

struct CCPaginatedResponse<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}

struct CCEmptyResponse: Decodable {}
