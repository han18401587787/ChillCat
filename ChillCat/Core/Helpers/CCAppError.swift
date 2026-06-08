//
//  CCAppError.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCAppError: LocalizedError {
    case network(CCAPIError)
    case timeout
    case cancelled
    case business(code: Int, message: String)
    case validation(CCValidationError)
    case data(Error)
    case notFound
    case decodingFailed
    case authentication
    case tokenExpired
    case permissionDenied
    case fileNotFound(String)
    case fileWriteFailed(String)
    case fileReadFailed(String)
    case unknown(Error?)
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .network(let apiError):
            return apiError.errorDescription
        case .timeout:
            return "请求超时，请检查网络后重试"
        case .cancelled:
            return "请求已取消"
        case .business(_, let message):
            return message
        case .validation(let error):
            return error.errorDescription
        case .data(let error):
            return "数据处理失败: \(error.localizedDescription)"
        case .notFound:
            return "数据不存在"
        case .decodingFailed:
            return "数据解析失败"
        case .authentication, .tokenExpired:
            return "登录已过期，请重新登录"
        case .permissionDenied:
            return "没有权限执行此操作"
        case .fileNotFound(let path):
            return "文件未找到: \(path)"
        case .fileWriteFailed(let path):
            return "文件写入失败: \(path)"
        case .fileReadFailed(let path):
            return "文件读取失败: \(path)"
        case .unknown(let error):
            return error?.localizedDescription ?? "未知错误"
        case .notImplemented:
            return "功能尚未实现"
        }
    }

    var code: Int {
        switch self {
        case .network(let apiError):
            switch apiError {
            case .unauthorized: return 401
            case .serverError(let c): return c
            default: return -1
            }
        case .timeout: return -1001
        case .business(let code, _): return code
        case .authentication, .tokenExpired: return 401
        case .validation: return 400
        case .notFound: return 404
        default: return -9999
        }
    }

    var isRetryable: Bool {
        switch self {
        case .network, .timeout, .business, .unknown: return true
        default: return false
        }
    }
}

enum CCValidationError: LocalizedError {
    case emptyUsername
    case emptyPassword
    case invalidEmail
    case passwordTooShort(min: Int)
    case invalidPhoneNumber
    case invalidURL
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .emptyUsername: return "请输入用户名"
        case .emptyPassword: return "请输入密码"
        case .invalidEmail: return "邮箱格式不正确"
        case .passwordTooShort(let min): return "密码长度不能少于 \(min) 位"
        case .invalidPhoneNumber: return "手机号格式不正确"
        case .invalidURL: return "URL 格式不正确"
        case .custom(let message): return message
        }
    }
}

extension Error {
    var asCCAppError: CCAppError {
        switch self {
        case let appError as CCAppError:
            return appError
        case let apiError as CCAPIError:
            return .network(apiError)
        case let validationError as CCValidationError:
            return .validation(validationError)
        case let urlError as URLError:
            switch urlError.code {
            case .timedOut: return .timeout
            case .cancelled: return .cancelled
            case .notConnectedToInternet, .networkConnectionLost:
                return .network(.networkFailure(urlError))
            default: return .network(.networkFailure(urlError))
            }
        case is DecodingError:
            return .decodingFailed
        default:
            return .unknown(self)
        }
    }
}

typealias CCAppResult<T> = Result<T, CCAppError>
