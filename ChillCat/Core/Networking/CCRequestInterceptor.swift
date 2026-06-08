//
//  CCRequestInterceptor.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCRequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest
    func handle(response: HTTPURLResponse, data: Data) async throws
}
