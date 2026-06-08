//
//  CCLoginUseCase.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCLoginUseCase {
    private let userRepository: CCUserRepositoryProtocol

    init(userRepository: CCUserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute(username: String, password: String) async throws -> CCUser {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw CCAppError.validation(.emptyUsername)
        }
        guard !password.isEmpty else {
            throw CCAppError.validation(.emptyPassword)
        }
        guard password.count >= CCConstants.minPasswordLength else {
            throw CCAppError.validation(.passwordTooShort(min: CCConstants.minPasswordLength))
        }

        do {
            return try await userRepository.login(username: username, password: password)
        } catch {
            throw error.asCCAppError
        }
    }
}
