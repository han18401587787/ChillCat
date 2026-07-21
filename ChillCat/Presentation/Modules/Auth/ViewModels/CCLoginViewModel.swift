//
//  CCLoginViewModel.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CCLoginViewModel {
    var username = ""
    var password = ""
    var email = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var isLoggedIn = false
    var isRegisterMode = false

    private let loginUseCase: CCLoginUseCase
    private let userRepository: CCUserRepositoryProtocol

    init(loginUseCase: CCLoginUseCase, userRepository: CCUserRepositoryProtocol) {
        self.loginUseCase = loginUseCase
        self.userRepository = userRepository
    }

    var isFormValid: Bool {
        let usernameValid = !username.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordValid = !password.isEmpty && password.count >= CCConstants.minPasswordLength

        if isRegisterMode {
            let emailValid = email.contains("@") && email.contains(".")
            let passwordsMatch = password == confirmPassword
            return usernameValid && passwordValid && emailValid && passwordsMatch
        }

        return usernameValid && passwordValid
    }

    func submit() async {
        if isRegisterMode {
            await register()
        } else {
            await login()
        }
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        let watchdogID = CCLoadingWatchdog.shared.startWatching(label: "LoginViewModel.login")
        defer { CCLoadingWatchdog.shared.stopWatching(watchdogID) }

        do {
            let user = try await loginUseCase.execute(username: username, password: password)
            LogI("用户登录成功: \(user.id)", module: .auth, category: "Login")
            isLoggedIn = true
        } catch {
            let appError = error.asCCAppError
            errorMessage = appError.errorDescription
            LogE("登录失败", module: .auth, category: "Login", error: error)
        }

        isLoading = false
    }

    func register() async {
        guard isFormValid else {
            errorMessage = "请检查输入信息"
            return
        }

        isLoading = true
        errorMessage = nil
        let watchdogID = CCLoadingWatchdog.shared.startWatching(label: "LoginViewModel.register")
        defer { CCLoadingWatchdog.shared.stopWatching(watchdogID) }

        do {
            let user = try await userRepository.register(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password,
                email: email.trimmingCharacters(in: .whitespaces)
            )
            LogI("用户注册成功: \(user.id)", module: .auth, category: "Register")
            isLoggedIn = true
        } catch {
            let appError = error.asCCAppError
            errorMessage = appError.errorDescription
            LogE("注册失败", module: .auth, category: "Register", error: error)
        }

        isLoading = false
    }
}
