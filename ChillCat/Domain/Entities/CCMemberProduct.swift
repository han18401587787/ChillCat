//
//  CCMemberProduct.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCMemberProduct: Identifiable, Codable {
    let id: String
    let type: CCMemberType
    let price: Decimal
    let originalPrice: Decimal?
    let displayPrice: String
    let discountTag: String?

    var hasDiscount: Bool {
        guard let originalPrice else { return false }
        return originalPrice > price
    }
}
