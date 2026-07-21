//
//  CCProfileViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI
import Combine

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

    var totalCheckins: Int {
        user?.totalCheckins ?? 0
    }

    var streakDays: Int {
        user?.streakDays ?? 0
    }

    var resonanceCount: Int {
        user?.resonanceCount ?? 0
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await profileUseCase.fetchProfile()
        } catch {
            // 未登录或网络错误：不显示错误页，正常展示默认信息
            if let apiError = error as? CCAPIError, apiError == .unauthorized {
                user = nil
            } else {
                // 其他错误也静默处理，user 保持 nil，页面正常展示
                user = nil
            }
        }

        isLoading = false
    }

    func logout() async {
        await profileUseCase.logout()
        user = nil
    }
}
