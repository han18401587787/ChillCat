//
//  CCSearchView.swift
//  ChillCat
//

import SwiftUI

struct CCSearchView: View {
    @State private var viewModel: CCSearchViewModel
    @Environment(CCAppCoordinator.self) private var coordinator

    init() {
        let container = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCSearchViewModel(
            fetchFeedsUseCase: container.resolve()
        ))
    }

    var body: some View {
        Group {
            if viewModel.isEmpty {
                CCEmptyStateView(
                    title: "未找到结果",
                    message: "换个关键词试试",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                List(viewModel.results) { item in
                    Button(action: {
                        coordinator.navigate(to: .detail(id: item.id))
                    }) {
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
                                    .foregroundColor(.primary)

                                Text(item.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.query, prompt: "搜索内容")
        .onSubmit(of: .search) {
            Task { await viewModel.search() }
        }
        .overlay {
            if viewModel.isLoading {
                CCLoadingView(message: "搜索中...")
            }
        }
        .navigationTitle("搜索")
    }
}
