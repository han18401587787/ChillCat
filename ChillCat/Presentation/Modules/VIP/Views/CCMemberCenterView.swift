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
            VStack(spacing: XuanSpacing.lg) {
                memberHeader
                privilegeSection
                productSection
                purchaseHistoryLink
            }
            .padding()
        }
    }

    private var memberHeader: some View {
        VStack(spacing: XuanSpacing.sm) {
            Image(systemName: viewModel.isMember ? "crown.fill" : "crown")
                .font(.system(size: 48))
                .foregroundColor(viewModel.isMember ? Color.xuanApricotDark : Color.xuanTextSecondary)

            Text(viewModel.isMember ? "ChillCat 会员" : "开通 ChillCat 会员")
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.statusDescription)
                .font(.subheadline)
                .foregroundColor(Color.xuanTextSecondary)

            if viewModel.isMember {
                Text(viewModel.remainingText)
                    .font(.caption)
                    .foregroundColor(Color.xuanApricot)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.xuanApricot.opacity(0.1))
                    .cornerRadius(XuanRadius.sm)
            }
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.xuanSurface)
        .cornerRadius(XuanRadius.lg)
    }

    private var privilegeSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("会员权益")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: XuanSpacing.md) {
                ForEach(viewModel.privileges) { privilege in
                    VStack(spacing: XuanSpacing.sm) {
                        Image(systemName: privilege.iconName)
                            .font(.title3)
                            .foregroundColor(privilege.isHighlight ? Color.xuanApricotDark : Color.xuanApricot)

                        Text(privilege.title)
                            .font(.caption)
                            .fontWeight(.medium)

                        Text(privilege.description)
                            .font(.caption2)
                            .foregroundColor(Color.xuanTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(XuanSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }
            }
        }
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
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
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .foregroundColor(Color.xuanApricot)
            .padding(XuanSpacing.md)
            .background(Color.xuanSurface)
            .cornerRadius(XuanRadius.md)
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
                        .foregroundColor(Color.xuanTextPrimary)

                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.xuanApricot)
                }

                Spacer()

                if let tag = product.discountTag {
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.xuanDanger)
                        .cornerRadius(XuanRadius.sm)
                }

                Text("立即购买")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.xuanApricot)
                    .cornerRadius(XuanRadius.sm)
            }
            .padding(XuanSpacing.md)
            .background(Color.xuanSurface)
            .cornerRadius(XuanRadius.md)
        }
    }
}
