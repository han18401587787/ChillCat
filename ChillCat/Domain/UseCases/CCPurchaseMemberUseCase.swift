//
//  CCPurchaseMemberUseCase.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCPurchaseMemberUseCase {
    private let repository: CCMemberRepositoryProtocol

    init(repository: CCMemberRepositoryProtocol) {
        self.repository = repository
    }

    func execute(product: CCMemberProduct) async throws -> CCMemberInfo {
        try await repository.purchase(product: product)
    }

    func restorePurchases() async throws -> CCMemberInfo? {
        try await repository.restorePurchases()
    }
}
