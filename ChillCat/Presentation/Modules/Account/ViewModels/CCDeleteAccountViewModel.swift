//
//  CCDeleteAccountViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCDeleteAccountViewModel {
    var isDeleting = false
    var errorMessage: String?
    var isDeleted = false

    private let userRepository: CCUserRepositoryProtocol

    init(userRepository: CCUserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func deleteAccount() async {
        isDeleting = true
        errorMessage = nil
        do {
            try await userRepository.deleteAccount()
            isDeleted = true
        } catch {
            errorMessage = "注销失败，请检查网络后重试"
        }
        isDeleting = false
    }
}
