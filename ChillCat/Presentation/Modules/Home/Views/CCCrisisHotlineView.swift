//
//  CCCrisisHotlineView.swift
//  ChillCat
//
//  危机热线快速呼叫 — 适用于 Sheet 展示的精简紧急求助页
//

import SwiftUI

struct CCCrisisHotlineView: View {
        @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // 关闭按钮（Sheet 模式下使用）
            closeButton

            // 紧急图标 + 安抚语
            emergencyHeader

            // 三大热线呼叫按钮
            hotlineButtons

            // 紧急情况提示
            emergencyNotice
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.background)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Emergency Header

    private var emergencyHeader: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppTheme.warmGold.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.warmGold)
            }

            Text("你并不孤单，帮助就在身边")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("请勇敢伸出你的手，这些热线24小时有人倾听")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Hotline Buttons

    private var hotlineButtons: some View {
        VStack(spacing: AppSpacing.md) {
            largeCallButton(
                name: "全国24小时心理援助热线",
                number: "400-161-9995",
                icon: "phone.fill",
                color: AppTheme.primary
            )

            largeCallButton(
                name: "北京心理危机研究与干预中心",
                number: "010-82951332",
                icon: "phone.fill",
                color: AppTheme.accentMint
            )

            largeCallButton(
                name: "生命热线",
                number: "400-821-1215",
                icon: "phone.fill",
                color: AppTheme.warmPurple
            )
        }
    }

    private func largeCallButton(name: String, number: String, icon: String, color: Color) -> some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .cornerRadius(AppRadius.sm)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.medium)
                    Text(number)
                        .font(AppFont.title3)
                        .foregroundColor(color)
                        .fontWeight(.bold)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Emergency Notice

    private var emergencyNotice: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("紧急情况请立即拨打")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: AppSpacing.lg) {
                emergencyNumberLink(number: "120", label: "急救")
                emergencyNumberLink(number: "110", label: "报警")
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.3))
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }

    private func emergencyNumberLink(number: String, label: String) -> some View {
        Link(destination: URL(string: "tel:\(number)")!) {
            VStack(spacing: AppSpacing.xs) {
                Text(number)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.red)
                Text(label)
                    .font(AppFont.caption)
                    .foregroundColor(Color.red.opacity(0.8))
            }
            .frame(width: 100)
            .padding(.vertical, AppSpacing.md)
            .background(Color.red.opacity(0.08))
            .cornerRadius(AppRadius.md)
        }
    }
}
