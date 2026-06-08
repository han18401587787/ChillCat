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
    case voiceCheckin
    case journal
    case trends
    case meditation
    case courses
    case vipCenter
    case profile
    case privacy
    case dataManagement
    case faq
    case deleteAccount
    case settings
    case web(url: URL)

    var id: String {
        switch self {
        case .welcome: return "welcome"
        case .login: return "login"
        case .home: return "home"
        case .treeHole: return "treeHole"
        case .voiceCheckin: return "voiceCheckin"
        case .journal: return "journal"
        case .trends: return "trends"
        case .meditation: return "meditation"
        case .courses: return "courses"
        case .vipCenter: return "vipCenter"
        case .profile: return "profile"
        case .privacy: return "privacy"
        case .dataManagement: return "dataManagement"
        case .faq: return "faq"
        case .deleteAccount: return "deleteAccount"
        case .settings: return "settings"
        case .web(let url): return "web_\(url.absoluteString)"
        }
    }
}
