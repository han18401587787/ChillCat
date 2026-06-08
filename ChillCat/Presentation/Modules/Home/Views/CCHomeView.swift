//
//  CCHomeView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCHomeView: View {
    @State private var viewModel: CCHomeViewModel
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    init() {
        let container = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCHomeViewModel(
            fetchFeedsUseCase: container.resolve()
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                CCLoadingView(message: "加载中...")
            } else if let error = viewModel.errorMessage, viewModel.items.isEmpty {
                CCErrorView(error: CCAppError.business(code: -1, message: error)) {
                    await viewModel.loadItems()
                }
            } else if viewModel.items.isEmpty {
                CCEmptyStateView(
                    title: "暂无内容",
                    message: "这里还没有内容，请稍后再来看看",
                    actionTitle: "刷新",
                    action: { await viewModel.loadItems() }
                )
            } else {
                contentList
            }
        }
        .navigationTitle("首页")
        .task {
            await viewModel.loadItems()
        }
    }

    private var contentList: some View {
        List {
            ForEach(viewModel.items) { item in
                CCHomeItemRow(item: item)
                    .onAppear {
                        if item.id == viewModel.items.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

struct CCHomeItemRow: View {
    let item: CCFeedItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.imageName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
