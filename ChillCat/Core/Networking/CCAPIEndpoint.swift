//
//  CCAPIEndpoint.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCAPIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: CCHTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
    var queryParameters: [String: String]? { get }
    var timeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

extension CCAPIEndpoint {
    var timeout: TimeInterval { CCNetworkConfig.requestTimeout }
    var headers: [String: String]? { nil }
    var body: Encodable? { nil }
    var queryParameters: [String: String]? { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}
