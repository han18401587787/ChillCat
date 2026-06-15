//
//  CCMemberInfo.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCMemberInfo: Codable, Equatable {
    let type: CCMemberType
    let status: CCMemberStatus
    let startDate: Date
    let endDate: Date?
    let isAutoRenew: Bool
    let purchaseDate: Date

    var isValid: Bool {
        guard status == .active else { return false }
        guard let endDate else { return true }
        return endDate > Date()
    }

    var remainingDays: Int? {
        guard let endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: endDate).day
    }

    static var mock: CCMemberInfo {
        CCMemberInfo(
            type: .monthly, status: .active,
            startDate: Date(), endDate: Calendar.current.date(byAdding: .day, value: 23, to: Date()),
            isAutoRenew: true, purchaseDate: Date().addingTimeInterval(-7 * 86400)
        )
    }

    var statusDescription: String {
        switch status {
        case .active:
            if let days = remainingDays {
                return "会员到期: \(days) 天后"
            }
            return "永久有效"
        case .expired: return "已过期"
        case .cancelled: return "已取消自动续费"
        case .refunded: return "已退款"
        case .none: return "开通会员享受更多权益"
        }
    }
}
