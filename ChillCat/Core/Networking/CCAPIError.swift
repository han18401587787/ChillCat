//
//  CCAPIError.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case unprocessableEntity
    case tooManyRequests
    case redirection(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case networkFailure(Error)
    case decodingFailure(Error)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .invalidResponse:
            return "服务器响应异常"
        case .badRequest:
            return "请求参数错误"
        case .unauthorized:
            return "登录已过期，请重新登录"
        case .forbidden:
            return "无权限访问"
        case .notFound:
            return "请求的资源不存在"
        case .conflict:
            return "数据冲突"
        case .unprocessableEntity:
            return "请求数据格式错误"
        case .tooManyRequests:
            return "请求过于频繁，请稍后再试"
        case .redirection(let code):
            return "请求被重定向 (\(code))"
        case .serverError(let code):
            return "服务器繁忙，请稍后再试 (\(code))"
        case .unexpectedStatusCode(let code):
            return "未知错误 (\(code))"
        case .networkFailure(let error):
            return "网络连接失败: \(error.localizedDescription)"
        case .decodingFailure:
            return "数据解析失败"
        case .cancelled:
            return "请求已取消"
        }
    }

    static func == (lhs: CCAPIError, rhs: CCAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL): return true
        case (.invalidResponse, .invalidResponse): return true
        case (.unauthorized, .unauthorized): return true
        case (.forbidden, .forbidden): return true
        case (.notFound, .notFound): return true
        case (.serverError(let a), .serverError(let b)): return a == b
        case (.networkFailure, .networkFailure): return true
        case (.decodingFailure, .decodingFailure): return true
        default: return false
        }
    }
}
