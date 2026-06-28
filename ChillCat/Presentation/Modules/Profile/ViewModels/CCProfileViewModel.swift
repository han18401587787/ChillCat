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
            // 未登录不显示错误 — 页面正常展示默认信息
            if let apiError = error as? CCAPIError, apiError == .unauthorized {
                user = nil
            } else if let apiError = error as? CCAPIError {
                switch apiError {
                case .networkFailure:
                    errorMessage = "网络连接失败，请检查网络设置"
                case .serverError:
                    errorMessage = "服务器繁忙，请稍后重试"
                default:
                    errorMessage = "加载失败，请下拉刷新重试"
                }
            } else {
                errorMessage = "加载失败，请下拉刷新重试"
            }
        }

        isLoading = false
    }

    func logout() async {
        await profileUseCase.logout()
        user = nil
    }
}
