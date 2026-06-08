//
//  CCLogModule.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCLogModule: String, CaseIterable, Sendable {
    case `default`   = "Default"
    case network     = "Network"
    case auth        = "Auth"
    case ui          = "UI"
    case storage     = "Storage"
    case database    = "Database"
    case analytics   = "Analytics"
    case payment     = "Payment"
    case performance = "Performance"
    case di          = "DI"

    var displayName: String {
        switch self {
        case .default:   return "通用"
        case .network:   return "网络"
        case .auth:      return "认证"
        case .ui:        return "UI"
        case .storage:   return "存储"
        case .database:  return "数据库"
        case .analytics: return "统计"
        case .payment:   return "支付"
        case .performance: return "性能"
        case .di:        return "依赖注入"
        }
    }
}
