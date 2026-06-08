//
//  CCMessageListView.swift
//  ChillCat
//

import SwiftUI

struct CCMessageListView: View {
    @State private var viewModel: CCMessageViewModel
    @Environment(CCAppCoordinator.self) private var coordinator

    init() {
        let c = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCMessageViewModel(useCase: c.resolve()))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                CCLoadingView(message: "加载中...")
            } else if viewModel.messages.isEmpty {
                CCEmptyStateView(title: "暂无消息", message: "您还没有任何通知消息", actionTitle: nil, action: nil)
            } else {
                List(viewModel.messages) { msg in
                    Button(action: { Task { await viewModel.markRead(msg) } }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(msg.isRead ? Color.clear : Color.blue)
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(msg.title)
                                    .font(.subheadline)
                                    .fontWeight(msg.isRead ? .regular : .semibold)
                                    .foregroundColor(.primary)
                                Text(msg.content)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(msg.createdAt)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("消息")
        .task { await viewModel.load() }
    }
}
