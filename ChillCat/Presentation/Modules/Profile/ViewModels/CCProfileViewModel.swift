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
            if let apiError = error as? CCAPIError {
                switch apiError {
                case .unauthorized:
                    errorMessage = "登录已过期，请重新登录"
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
