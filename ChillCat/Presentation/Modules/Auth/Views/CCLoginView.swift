//
//  CCLoginView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCLoginView: View {
    @State private var viewModel: CCLoginViewModel
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    init() {
        let container = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCLoginViewModel(
            loginUseCase: CCLoginUseCase(userRepository: container.resolve()),
            userRepository: container.resolve()
        ))
    }

    var body: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer()

            VStack(spacing: theme.spacingSM) {
                Image(systemName: "cat.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.primary)

                Text("ChillCat")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("享受轻松生活")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()

            VStack(spacing: theme.spacingMD) {
                TextField("用户名", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("密码 (至少\(CCConstants.minPasswordLength)位)", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(viewModel.isRegisterMode ? .newPassword : .password)

                if viewModel.isRegisterMode {
                    SecureField("确认密码", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)

                    TextField("邮箱", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(theme.error)
                        .padding(.horizontal, theme.spacingSM)
                }

                Button(action: {
                    Task {
                        await viewModel.submit()
                        if viewModel.isLoggedIn {
                            coordinator.isLoggedIn = true
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(viewModel.isRegisterMode ? "注册" : "登录")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormValid ? theme.primary : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(theme.radiusMD)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)

                Button(action: {
                    withAnimation {
                        viewModel.isRegisterMode.toggle()
                        viewModel.errorMessage = nil
                    }
                }) {
                    Text(viewModel.isRegisterMode ? "已有账号？去登录" : "没有账号？去注册")
                        .font(.subheadline)
                        .foregroundColor(theme.primary)
                }
            }
            .padding(.horizontal, theme.spacingXL)

            Spacer()
        }
        .padding()
        .background(theme.background)
        .navigationBarHidden(true)
    }
}
