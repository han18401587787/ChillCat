//
//  CCUserAPI.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCUserAPI {
    case login(username: String, password: String)
    case register(username: String, password: String, email: String)
    case profile
    case updateProfile(name: String)
    case logout
    case deleteAccount
}

extension CCUserAPI: CCAPIEndpoint {
    var baseURL: URL { CCAppEnvironment.current.baseURL }

    var path: String {
        switch self {
        case .login: return "/api/v1/auth/login"
        case .register: return "/api/v1/auth/register"
        case .profile: return "/api/v1/user/profile"
        case .updateProfile: return "/api/v1/user/profile"
        case .logout: return "/api/v1/auth/logout"
        case .deleteAccount: return "/api/v1/user/account"
        }
    }

    var method: CCHTTPMethod {
        switch self {
        case .login, .register, .updateProfile: return .post
        case .profile, .logout: return .get
        case .deleteAccount: return .delete
        }
    }

    var body: Encodable? {
        switch self {
        case .login(let username, let password):
            return ["username": username, "password": password]
        case .register(let username, let password, let email):
            return ["username": username, "password": password, "email": email]
        case .updateProfile(let name):
            return ["name": name]
        default:
            return nil
        }
    }
}
