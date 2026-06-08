//
//  CCMemberPurchaseView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCMemberPurchaseView: View {
    let product: CCMemberProduct
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @State private var isPurchasing = false
    @State private var purchaseComplete = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if purchaseComplete {
                successView
            } else {
                confirmView
            }
        }
        .navigationTitle("确认购买")
    }

    private var confirmView: some View {
        VStack(spacing: theme.spacingLG) {
            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundColor(theme.warning)
                .padding(.top, theme.spacingXL)

            VStack(spacing: theme.spacingSM) {
                Text(product.type.displayName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(product.displayPrice)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(theme.primary)
            }

            VStack(spacing: theme.spacingSM) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.success)
                    Text("即时开通，畅享全部会员权益")
                        .font(.subheadline)
                    Spacer()
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.success)
                    Text("支持随时取消自动续费")
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(.horizontal, theme.spacingXL)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(theme.error)
            }

            Spacer()

            VStack(spacing: theme.spacingSM) {
                Button(action: { purchase() }) {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text("确认支付 \(product.displayPrice)")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.primary)
                .foregroundColor(.white)
                .cornerRadius(theme.radiusMD)
                .disabled(isPurchasing)

                Button("取消") { coordinator.pop() }
                    .foregroundColor(theme.textSecondary)
            }
            .padding(.horizontal, theme.spacingXL)
            .padding(.bottom, theme.spacingLG)
        }
    }

    private var successView: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(theme.success)
            Text("购买成功！")
                .font(.title)
                .fontWeight(.bold)
            Text("您已成为 ChillCat \(product.type.displayName)")
                .foregroundColor(theme.textSecondary)
            Spacer()
            Button("返回会员中心") { coordinator.pop() }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, theme.spacingXL)
        }
    }

    private func purchase() {
        isPurchasing = true
        errorMessage = nil
        // 模拟购买流程（后续接入 StoreKit）
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isPurchasing = false
            purchaseComplete = true
        }
    }
}
