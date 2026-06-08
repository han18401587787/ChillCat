//
//  CCMemberRepository.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCMemberRepository: CCMemberRepositoryProtocol {
    private let remoteDataSource: CCMemberRemoteDataSource
    private let localDataSource: CCMemberLocalDataSource

    init(
        remoteDataSource: CCMemberRemoteDataSource,
        localDataSource: CCMemberLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchMemberInfo() async throws -> CCMemberInfo {
        if let cached = try? localDataSource.getCachedMemberInfo() {
            return cached
        }
        let dto = try await remoteDataSource.fetchMemberInfo()
        let info = CCMemberDTOMapper.toEntity(dto)
        try? localDataSource.cacheMemberInfo(info)
        return info
    }

    func fetchProducts() async throws -> [CCMemberProduct] {
        let dtos = try await remoteDataSource.fetchProducts()
        return dtos.map { CCMemberDTOMapper.toEntity($0) }
    }

    func fetchPrivileges() async throws -> [CCMemberPrivilege] {
        let dtos = try await remoteDataSource.fetchPrivileges()
        return dtos.map { CCMemberDTOMapper.toEntity($0) }
    }

    func purchase(product: CCMemberProduct) async throws -> CCMemberInfo {
        let dto = try await remoteDataSource.purchase(productId: product.id)
        let info = CCMemberDTOMapper.toEntity(dto)
        try? localDataSource.cacheMemberInfo(info)
        return info
    }

    func restorePurchases() async throws -> CCMemberInfo? {
        try await fetchMemberInfo()
    }
}
