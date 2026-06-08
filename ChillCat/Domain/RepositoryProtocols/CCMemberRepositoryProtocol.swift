//
//  CCMemberRepositoryProtocol.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCMemberRepositoryProtocol {
    func fetchMemberInfo() async throws -> CCMemberInfo
    func fetchProducts() async throws -> [CCMemberProduct]
    func fetchPrivileges() async throws -> [CCMemberPrivilege]
    func purchase(product: CCMemberProduct) async throws -> CCMemberInfo
    func restorePurchases() async throws -> CCMemberInfo?
}
