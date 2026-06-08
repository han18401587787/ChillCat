//
//  CCMemberStatus.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCMemberStatus: String, Codable {
    case active     = "active"
    case expired    = "expired"
    case cancelled  = "cancelled"
    case refunded   = "refunded"
    case none       = "none"

    var isActive: Bool { self == .active }

    var displayName: String {
        switch self {
        case .active:    return "有效"
        case .expired:   return "已过期"
        case .cancelled: return "已取消"
        case .refunded:  return "已退款"
        case .none:      return "非会员"
        }
    }
}
