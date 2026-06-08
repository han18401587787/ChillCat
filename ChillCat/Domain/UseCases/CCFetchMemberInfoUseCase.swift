//
//  CCFetchMemberInfoUseCase.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCFetchMemberInfoUseCase {
    private let repository: CCMemberRepositoryProtocol

    init(repository: CCMemberRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> CCMemberInfo {
        try await repository.fetchMemberInfo()
    }
}
