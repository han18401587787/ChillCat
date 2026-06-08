//
//  CCProfileView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCProfileView: View {
    @State private var viewModel: CCProfileViewModel
    @Environment(CCAppCoordinator.self) private var coordinator

    init() {
        let container = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCProfileViewModel(
            profileUseCase: container.resolve()
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.user == nil {
                CCLoadingView(message: "加载中...")
            } else if let error = viewModel.errorMessage, viewModel.user == nil {
                CCErrorView(error: CCAppError.business(code: -1, message: error)) {
                    await viewModel.loadProfile()
                }
            } else {
                contentList
            }
        }
        .navigationTitle("我的")
        .task {
            await viewModel.loadProfile()
        }
    }

    private var contentList: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(viewModel.displayEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section {
                Button(action: {
                    coordinator.navigate(to: .messages)
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.red)
                        Text("消息中心")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    coordinator.navigate(to: .vipCenter)
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                        Text("会员中心")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Button(action: {
                    coordinator.navigate(to: .settings)
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                        Text("设置")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                Button(role: .destructive, action: {
                    Task {
                        await viewModel.logout()
                        coordinator.isLoggedIn = false
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("退出登录")
                        Spacer()
                    }
                }
            }
        }
    }
}
