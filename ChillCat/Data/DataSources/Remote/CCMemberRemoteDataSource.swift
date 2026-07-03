//
//  CCMemberRemoteDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCMemberRemoteDataSource {

    func fetchMemberInfo() async throws -> CCMemberInfoDTO {
        try await CCXuanAPI.getMemberInfo()
    }

    func fetchProducts() async throws -> [CCMemberProductDTO] {
        try await CCXuanAPI.getMemberProducts()
    }

    func fetchPrivileges() async throws -> [CCMemberPrivilegeDTO] {
        try await CCXuanAPI.getMemberPrivileges()
    }

    func purchase(productId: String) async throws -> CCMemberInfoDTO {
        try await CCXuanAPI.purchaseMember(productId: productId)
    }
}
