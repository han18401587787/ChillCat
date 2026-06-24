//
//  CCCrisisHotlineView.swift
//  ChillCat
//
//  危机热线快速呼叫 — 适用于 Sheet 展示的精简紧急求助页
//

import SwiftUI

struct CCCrisisHotlineView: View {
    @Environment(\.ccAppTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: theme.spacing2XL) {
            // 关闭按钮（Sheet 模式下使用）
            closeButton

            // 紧急图标 + 安抚语
            emergencyHeader

            // 三大热线呼叫按钮
            hotlineButtons

            // 紧急情况提示
            emergencyNotice
        }
        .padding(theme.spacingXL)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(theme.background)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.textMuted)
            }
        }
    }

    // MARK: - Emergency Header

    private var emergencyHeader: some View {
        VStack(spacing: theme.spacingLG) {
            ZStack {
                Circle()
                    .fill(theme.warmLight.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 44))
                    .foregroundColor(theme.warm)
            }

            Text("你并不孤单，帮助就在身边")
                .font(theme.fontH2)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)

            Text("请勇敢伸出你的手，这些热线24小时有人倾听")
                .font(theme.fontBody)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Hotline Buttons

    private var hotlineButtons: some View {
        VStack(spacing: theme.spacingMD) {
            largeCallButton(
                name: "全国24小时心理援助热线",
                number: "400-161-9995",
                icon: "phone.fill",
                color: theme.primary
            )

            largeCallButton(
                name: "北京心理危机研究与干预中心",
                number: "010-82951332",
                icon: "phone.fill",
                color: theme.softGreen
            )

            largeCallButton(
                name: "生命热线",
                number: "400-821-1215",
                icon: "phone.fill",
                color: theme.softPurple
            )
        }
    }

    private func largeCallButton(name: String, number: String, icon: String, color: Color) -> some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack(spacing: theme.spacingMD) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .cornerRadius(theme.radiusSM)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(theme.fontBodyL)
                        .foregroundColor(theme.textPrimary)
                        .fontWeight(.medium)
                    Text(number)
                        .font(theme.fontH3)
                        .foregroundColor(color)
                        .fontWeight(.bold)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusLG)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusLG)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Emergency Notice

    private var emergencyNotice: some View {
        VStack(spacing: theme.spacingSM) {
            Text("紧急情况请立即拨打")
                .font(theme.fontBody)
                .foregroundColor(theme.textSecondary)

            HStack(spacing: theme.spacingLG) {
                emergencyNumberLink(number: "120", label: "急救")
                emergencyNumberLink(number: "110", label: "报警")
            }
        }
        .padding(theme.spacingXL)
        .frame(maxWidth: .infinity)
        .background(theme.errorLight)
        .cornerRadius(theme.radiusLG)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radiusLG)
                .stroke(theme.error.opacity(0.3), lineWidth: 1)
        )
    }

    private func emergencyNumberLink(number: String, label: String) -> some View {
        Link(destination: URL(string: "tel:\(number)")!) {
            VStack(spacing: theme.spacingXS) {
                Text(number)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.error)
                Text(label)
                    .font(theme.fontCaption)
                    .foregroundColor(theme.error.opacity(0.8))
            }
            .frame(width: 100)
            .padding(.vertical, theme.spacingMD)
            .background(theme.error.opacity(0.08))
            .cornerRadius(theme.radiusMD)
        }
    }
}
