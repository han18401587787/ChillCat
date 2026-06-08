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
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                memberHeader
                privilegeSection
                productSection
            }
            .padding()
        }
    }

    private var memberHeader: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: viewModel.isMember ? "crown.fill" : "crown")
                .font(.system(size: 48))
                .foregroundColor(viewModel.isMember ? theme.warning : theme.textSecondary)

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
                            .foregroundColor(privilege.isHighlight ? theme.warning : theme.primary)

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

    private func productCard(_ product: CCMemberProduct) -> some View {
        Button(action: {
            Task { await viewModel.purchase(product: product) }
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
