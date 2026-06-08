//
//  CCAppRoute.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCAppRoute: Hashable, Identifiable {
    case login
    case home
    case profile
    case messages
    case search
    case vipCenter
    case vipPurchase
    case settings
    case detail(id: String)
    case web(url: URL)

    var id: String {
        switch self {
        case .login: return "login"
        case .home: return "home"
        case .profile: return "profile"
        case .messages: return "messages"
        case .search: return "search"
        case .vipCenter: return "vipCenter"
        case .vipPurchase: return "vipPurchase"
        case .settings: return "settings"
        case .detail(let id): return "detail_\(id)"
        case .web(let url): return "web_\(url.absoluteString)"
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .detail(let id):
            hasher.combine("detail")
            hasher.combine(id)
        case .web(let url):
            hasher.combine("web")
            hasher.combine(url)
        default:
            hasher.combine(id)
        }
    }
}
