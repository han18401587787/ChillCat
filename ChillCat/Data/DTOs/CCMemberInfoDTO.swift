//
//  CCMemberInfoDTO.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCMemberInfoDTO: Decodable {
    let memberType: String
    let status: String
    let startDate: String
    let endDate: String?
    let autoRenew: Bool
    let purchaseDate: String
}

struct CCMemberProductDTO: Decodable {
    let productId: String
    let memberType: String
    let price: String
    let originalPrice: String?
    let discountTag: String?
}

struct CCMemberPrivilegeDTO: Decodable {
    let privilegeId: String
    let title: String
    let description: String
    let icon: String
    let highlight: Bool
    let availableTypes: [String]
}

enum CCMemberDTOMapper {
    static func toEntity(_ dto: CCMemberInfoDTO) -> CCMemberInfo {
        CCMemberInfo(
            type: CCMemberType(rawValue: dto.memberType) ?? .monthly,
            status: CCMemberStatus(rawValue: dto.status) ?? .none,
            startDate: Date.cc_fromISO8601(dto.startDate) ?? Date(),
            endDate: dto.endDate.flatMap { Date.cc_fromISO8601($0) },
            isAutoRenew: dto.autoRenew,
            purchaseDate: Date.cc_fromISO8601(dto.purchaseDate) ?? Date()
        )
    }

    static func toEntity(_ dto: CCMemberProductDTO) -> CCMemberProduct {
        CCMemberProduct(
            id: dto.productId,
            type: CCMemberType(rawValue: dto.memberType) ?? .monthly,
            price: Decimal(string: dto.price) ?? 0,
            originalPrice: dto.originalPrice.flatMap { Decimal(string: $0) },
            displayPrice: "¥\(dto.price)",
            discountTag: dto.discountTag
        )
    }

    static func toEntity(_ dto: CCMemberPrivilegeDTO) -> CCMemberPrivilege {
        CCMemberPrivilege(
            id: dto.privilegeId,
            title: dto.title,
            description: dto.description,
            iconName: dto.icon,
            isHighlight: dto.highlight,
            availableTypes: dto.availableTypes.compactMap { CCMemberType(rawValue: $0) }
        )
    }
}
