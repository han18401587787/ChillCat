//
//  CCMemberType.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCMemberType: String, Codable, CaseIterable, Hashable {
    case monthly    = "monthly"
    case quarterly  = "quarterly"
    case yearly     = "yearly"
    case permanent  = "permanent"

    var displayName: String {
        switch self {
        case .monthly:   return "月度会员"
        case .quarterly: return "季度会员"
        case .yearly:    return "年度会员"
        case .permanent: return "永久会员"
        }
    }

    var isSubscription: Bool {
        switch self {
        case .monthly, .quarterly, .yearly: return true
        case .permanent: return false
        }
    }

    var durationDays: Int? {
        switch self {
        case .monthly: return 30
        case .quarterly: return 90
        case .yearly: return 365
        case .permanent: return nil
        }
    }
}
