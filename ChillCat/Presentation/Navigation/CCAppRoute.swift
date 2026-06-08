//
//  CCAppRoute.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCAppRoute: Hashable, Identifiable {
    case welcome
    case login
    case home
    case treeHole
    case vipCenter
    case profile
    case settings
    case web(url: URL)

    var id: String {
        switch self {
        case .welcome: return "welcome"
        case .login: return "login"
        case .home: return "home"
        case .treeHole: return "treeHole"
        case .vipCenter: return "vipCenter"
        case .profile: return "profile"
        case .settings: return "settings"
        case .web(let url): return "web_\(url.absoluteString)"
        }
    }
}
