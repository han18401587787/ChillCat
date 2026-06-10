//
//  CCTransactionHistoryView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import SwiftUI

struct CCTransactionHistoryView: View {
    @State private var viewModel = CCOrderTrackingViewModel()
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        Group {
            if viewModel.isLoading {
                CCLoadingView(message: "加载中...")
            } else if viewModel.transactions.isEmpty {
                CCEmptyStateView(
                    title: "暂无购买记录",
                    message: "您的购买记录将在这里显示",
                    imageName: "clock.arrow.circlepath"
                )
            } else {
                List {
                    ForEach(viewModel.transactions) { transaction in
                        transactionRow(transaction)
                            .listRowBackground(theme.surface)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.background)
            }
        }
        .navigationTitle("购买记录")
        .task { viewModel.load() }
        .alert("加载失败", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("重试") {
                viewModel.load()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "加载购买记录失败")
        }
    }

    private func transactionRow(_ transaction: CCTransaction) -> some View {
        HStack(spacing: theme.spacingMD) {
            Image(systemName: transaction.status.systemImage)
                .font(.title3)
                .foregroundColor(statusColor(transaction.status))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.productType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.purchaseDate.cc_formatted("yyyy-MM-dd HH:mm"))
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(NSDecimalNumber(decimal: transaction.amount).stringValue)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(transaction.status.displayName)
                    .font(.caption)
                    .foregroundColor(statusColor(transaction.status))
            }
        }
        .padding(.vertical, 4)
    }

    private func statusColor(_ status: CCTransactionStatus) -> Color {
        switch status {
        case .pending:   return theme.warm
        case .completed: return theme.success
        case .failed:    return theme.error
        case .refunded:  return theme.textMuted
        }
    }
}
