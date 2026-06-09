//
//  CCTransaction.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import Foundation

enum CCTransactionStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case failed
    case refunded

    var displayName: String {
        switch self {
        case .pending:   return "处理中"
        case .completed: return "已完成"
        case .failed:    return "失败"
        case .refunded:  return "已退款"
        }
    }

    var systemImage: String {
        switch self {
        case .pending:   return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        case .failed:    return "xmark.circle.fill"
        case .refunded:  return "arrow.uturn.backward.circle.fill"
        }
    }
}

struct CCTransaction: Identifiable, Codable, Equatable {
    let id: String
    let productType: CCMemberType
    let amount: Decimal
    let purchaseDate: Date
    let status: CCTransactionStatus
    let receiptURL: String?

    init(
        id: String = UUID().uuidString,
        productType: CCMemberType,
        amount: Decimal,
        purchaseDate: Date = Date(),
        status: CCTransactionStatus = .pending,
        receiptURL: String? = nil
    ) {
        self.id = id
        self.productType = productType
        self.amount = amount
        self.purchaseDate = purchaseDate
        self.status = status
        self.receiptURL = receiptURL
    }
}
