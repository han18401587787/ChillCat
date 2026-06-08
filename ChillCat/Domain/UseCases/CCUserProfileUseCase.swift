//
//  CCUserProfileUseCase.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCUserProfileUseCase {
    private let userRepository: CCUserRepositoryProtocol

    init(userRepository: CCUserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func fetchProfile() async throws -> CCUser {
        try await userRepository.fetchProfile()
    }

    func updateProfile(_ user: CCUser) async throws -> CCUser {
        try await userRepository.updateProfile(user)
    }

    func logout() async {
        await userRepository.logout()
    }
}
