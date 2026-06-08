//
//  CCProfileViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCProfileViewModel {
    var user: CCUser?
    var isLoading = false
    var errorMessage: String?

    private let profileUseCase: CCUserProfileUseCase

    init(profileUseCase: CCUserProfileUseCase) {
        self.profileUseCase = profileUseCase
    }

    var displayName: String {
        user?.name ?? "未登录"
    }

    var displayEmail: String {
        user?.email ?? ""
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await profileUseCase.fetchProfile()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() async {
        await profileUseCase.logout()
        user = nil
    }
}
