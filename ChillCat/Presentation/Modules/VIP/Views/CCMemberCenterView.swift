//
//  CCMemberCenterView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCMemberCenterView: View {
    @State private var viewModel: CCMemberViewModel
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    init() {
        let container = CCAppDependencyContainer.shared.container
        _viewModel = State(initialValue: CCMemberViewModel(
            fetchMemberInfoUseCase: CCFetchMemberInfoUseCase(repository: container.resolve()),
            purchaseMemberUseCase: CCPurchaseMemberUseCase(repository: container.resolve())
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                CCLoadingView(message: "加载中...")
            } else {
                content
            }
        }
        .navigationTitle("会员中心")
        .task { await viewModel.loadData() }
        .sheet(isPresented: $viewModel.showConfirmSheet) {
            if let product = viewModel.selectedProduct {
                CCPaymentConfirmSheet(
                    product: product,
                    onConfirm: { await viewModel.confirmPurchase() },
                    onDismiss: { viewModel.selectedProduct = nil }
                )
            }
        }
        .alert("购买成功", isPresented: $viewModel.showSuccessAlert) {
            Button("好的") {
                viewModel.selectedProduct = nil
            }
        } message: {
            Text("恭喜成为 ChillCat 会员，即刻享受全部权益")
        }
        .alert("购买失败", isPresented: $viewModel.showFailureAlert) {
            Button("重试") {
                Task {
                    await viewModel.confirmPurchase()
                }
            }
            Button("取消", role: .cancel) {
                viewModel.selectedProduct = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "支付失败，请稍后重试")
        }
        .alert("加载失败", isPresented: $viewModel.showLoadErrorAlert) {
            Button("重试") {
                Task { await viewModel.loadData() }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "加载数据失败，请检查网络后重试")
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                memberHeader
                privilegeSection
                productSection
                purchaseHistoryLink
            }
            .padding()
        }
    }

    private var memberHeader: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: viewModel.isMember ? "crown.fill" : "crown")
                .font(.system(size: 48))
                .foregroundColor(viewModel.isMember ? theme.warm : theme.textSecondary)

            Text(viewModel.isMember ? "ChillCat 会员" : "开通 ChillCat 会员")
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.statusDescription)
                .font(.subheadline)
                .foregroundColor(theme.textSecondary)

            if viewModel.isMember {
                Text(viewModel.remainingText)
                    .font(.caption)
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(theme.primary.opacity(0.1))
                    .cornerRadius(theme.radiusSM)
            }
        }
        .padding(theme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(theme.surface)
        .cornerRadius(theme.radiusLG)
    }

    private var privilegeSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            Text("会员权益")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacingMD) {
                ForEach(viewModel.privileges) { privilege in
                    VStack(spacing: theme.spacingSM) {
                        Image(systemName: privilege.iconName)
                            .font(.title3)
                            .foregroundColor(privilege.isHighlight ? theme.warm : theme.primary)

                        Text(privilege.title)
                            .font(.caption)
                            .fontWeight(.medium)

                        Text(privilege.description)
                            .font(.caption2)
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(theme.spacingSM)
                    .frame(maxWidth: .infinity)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }
            }
        }
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            Text("选择套餐")
                .font(.headline)

            ForEach(viewModel.products) { product in
                productCard(product)
            }
        }
    }

    private var purchaseHistoryLink: some View {
        Button(action: { coordinator.navigate(to: .transactionHistory) }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text("购买记录")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }
            .foregroundColor(theme.primary)
            .padding(theme.spacingMD)
            .background(theme.surface)
            .cornerRadius(theme.radiusMD)
        }
    }

    private func productCard(_ product: CCMemberProduct) -> some View {
        Button(action: {
            viewModel.requestPurchase(product: product)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.type.displayName)
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)

                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.primary)
                }

                Spacer()

                if let tag = product.discountTag {
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.error)
                        .cornerRadius(theme.radiusSM)
                }

                Text("立即购买")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(theme.primary)
                    .cornerRadius(theme.radiusSM)
            }
            .padding(theme.spacingMD)
            .background(theme.surface)
            .cornerRadius(theme.radiusMD)
        }
    }
}
