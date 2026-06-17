//
//  CCPaymentConfirmSheet.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import SwiftUI

struct CCPaymentConfirmSheet: View {
    let product: CCMemberProduct
    let onConfirm: () async -> Void
    let onDismiss: () -> Void

    @State private var isProcessing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                headerSection
                detailSection
                Spacer()
                actionButtons
            }
            .padding()
            .navigationTitle("确认购买")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss(); onDismiss() }
                        .disabled(isProcessing)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.warm)

            Text(product.type.displayName)
                .font(.title3)
                .fontWeight(.bold)

            Text(product.displayPrice)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(AppTheme.primary)

            if let originalPrice = product.originalPrice {
                Text("原价 \(originalPrice.formatted())")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .strikethrough()
            }

            if let discountTag = product.discountTag {
                Text(discountTag)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppTheme.error)
                    .cornerRadius(AppRadius.sm)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface)
        .cornerRadius(AppRadius.lg)
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("购买详情")
                .font(.headline)

            VStack(spacing: 12) {
                detailRow(icon: "tag.fill", title: "套餐类型", value: product.type.displayName)
                if let days = product.type.durationDays {
                    detailRow(icon: "calendar", title: "有效期", value: "\(days) 天")
                } else {
                    detailRow(icon: "infinity", title: "有效期", value: "永久有效")
                }
                detailRow(icon: "yensign.circle.fill", title: "支付金额", value: product.displayPrice)
                if product.type.isSubscription {
                    detailRow(icon: "arrow.triangle.2.circlepath", title: "续费方式", value: "自动续费，可随时取消")
                } else {
                    detailRow(icon: "checkmark.shield.fill", title: "购买方式", value: "一次性买断")
                }
            }
            .padding(AppSpacing.md)
            .background(AppTheme.surface)
            .cornerRadius(AppRadius.md)
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: {
                isProcessing = true
                Task {
                    await onConfirm()
                    isProcessing = false
                    dismiss()
                }
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isProcessing ? "处理中..." : "确认支付 \(product.displayPrice)")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isProcessing ? AppTheme.primary.opacity(0.5) : AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(AppRadius.md)
            }
            .disabled(isProcessing)

            Text("支付即表示您同意服务条款和隐私政策")
                .font(.caption2)
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
        }
    }
}
