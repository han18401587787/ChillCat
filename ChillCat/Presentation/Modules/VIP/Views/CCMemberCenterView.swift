//
//  CCMemberCenterView.swift
//  绪安 - 心光会员中心 (严格对照设计稿 page_16/48 像素级还原)
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
        .background(Color.xuanApricotBg)
        .navigationTitle("心光会员")
        .navigationBarTitleDisplayMode(.large)
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
            Button("好的") { viewModel.selectedProduct = nil }
        } message: {
            Text("恭喜成为绪安心光会员，即刻享受全部权益")
        }
        .alert("购买失败", isPresented: $viewModel.showFailureAlert) {
            Button("重试") { Task { await viewModel.confirmPurchase() } }
            Button("取消", role: .cancel) { viewModel.selectedProduct = nil }
        } message: {
            Text(viewModel.errorMessage ?? "支付失败，请稍后重试")
        }
        .alert("加载失败", isPresented: $viewModel.showLoadErrorAlert) {
            Button("重试") { Task { await viewModel.loadData() } }
            Button("取消", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "加载数据失败")
        }
        .trackPage("VIP:CCMemberCenterView")
    }

    // MARK: - 主内容
    private var content: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 顶部会员卡片
                memberHeaderCard

                // 会员权益网格
                privilegeSection

                // 套餐选择
                productSection

                // 购买记录
                purchaseHistoryLink
            }
            .padding(XuanSpacing.lg)
        }
    }

    // MARK: - 会员头部卡片 (渐变背景)
    private var memberHeaderCard: some View {
        VStack(spacing: XuanSpacing.md) {
            // 皇冠图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 72, height: 72)
                CCIconMapper.image(for: viewModel.isMember ? "crown.fill" : "crown")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: XuanSpacing.xs) {
                Text(viewModel.isMember ? "心光会员" : "开通心光会员")
                    .font(XuanFont.h2)
                    .foregroundColor(.white)

                Text(viewModel.isMember ? "你已是心光会员" : "首月仅需 ¥9.9，解锁更多治愈功能")
                    .font(XuanFont.bodyM)
                    .foregroundColor(.white.opacity(0.85))
            }

            if viewModel.isMember {
                Text(viewModel.remainingText)
                    .font(XuanFont.bodyS)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.xs)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(XuanRadius.full)
            }
        }
        .padding(.vertical, XuanSpacing.xl3)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "D4A882"), Color.xuanApricot, Color(hex: "F2DBC9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color(hex: "D4A882").opacity(0.25), radius: 12, x: 0, y: 4)
    }

    // MARK: - 会员权益
    private var privilegeSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("会员权益")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm)
                ],
                spacing: XuanSpacing.sm
            ) {
                ForEach(viewModel.privileges) { privilege in
                    VStack(spacing: XuanSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(
                                    privilege.isHighlight
                                        ? Color.xuanApricot.opacity(0.15)
                                        : Color.xuanSurface
                                )
                                .frame(width: 44, height: 44)
                            CCIconMapper.image(for: privilege.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(
                                    privilege.isHighlight
                                        ? Color.xuanApricotDark
                                        : Color.xuanApricot
                                )
                        }

                        Text(privilege.title)
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextPrimary)

                        Text(privilege.description)
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(XuanSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.md)
                    .accessibilityIdentifier("member_privilege_\(privilege.title)")
                }
            }
        }
    }

    // MARK: - 套餐选择
    private var productSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("选择套餐")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                ForEach(viewModel.products) { product in
                    productCard(product)
                }
            }
        }
    }

    private func productCard(_ product: CCMemberProduct) -> some View {
        Button(action: { viewModel.requestPurchase(product: product) }) {
            HStack(spacing: XuanSpacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.type.displayName)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text(product.displayPrice)
                        .font(XuanFont.h2)
                        .foregroundColor(Color.xuanApricotDark)
                }

                Spacer()

                if let tag = product.discountTag {
                    Text(tag)
                        .font(XuanFont.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.xuanDanger)
                        .cornerRadius(XuanRadius.sm)
                }

                Text("立即开通")
                    .font(XuanFont.bodyS)
                    .foregroundColor(.white)
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.xuanApricot)
                    .cornerRadius(XuanRadius.md)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("member_purchase_\(product.type.displayName)")
    }

    // MARK: - 购买记录
    private var purchaseHistoryLink: some View {
        Button(action: { coordinator.navigate(to: .transactionHistory) }) {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.sm)
                        .fill(Color.xuanApricot.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image("ai_history")
                        .font(.system(size: 16))
                        .foregroundColor(Color.xuanApricot)
                }

                Text("购买记录")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)

                Spacer()

                Image("common_more")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.xuanTextTertiary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("member_purchase_history")
    }
