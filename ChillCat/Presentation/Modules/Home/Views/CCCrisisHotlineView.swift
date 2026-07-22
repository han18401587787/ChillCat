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
        VStack(spacing: XuanSpacing.xl) {
            // 关闭按钮（Sheet 模式下使用）
            closeButton

            // 紧急图标 + 安抚语
            emergencyHeader

            // 三大热线呼叫按钮
            hotlineButtons

            // 紧急情况提示
            emergencyNotice
        }
        .padding(XuanSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.xuanApricotBg)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image("common_close")
                    .font(.system(size: 28))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .accessibilityIdentifier("crisis_hotline_close")
        }
    }

    // MARK: - Emergency Header

    private var emergencyHeader: some View {
        VStack(spacing: XuanSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.xuanApricotDark.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image("healing_bookmark")
                    .font(.system(size: 44))
                    .foregroundColor(Color.xuanApricotDark)
            }

            Text("你并不孤单，帮助就在身边")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
                .multilineTextAlignment(.center)

            Text("请勇敢伸出你的手，这些热线24小时有人倾听")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Hotline Buttons

    private var hotlineButtons: some View {
        VStack(spacing: XuanSpacing.md) {
            largeCallButton(
                name: "全国24小时心理援助热线",
                number: "400-161-9995",
                icon: "phone.fill",
                color: Color.xuanApricot
            )
            .accessibilityIdentifier("crisis_hotline_national")

            largeCallButton(
                name: "北京心理危机研究与干预中心",
                number: "010-82951332",
                icon: "phone.fill",
                color: Color.xuanMint
            )
            .accessibilityIdentifier("crisis_hotline_beijing")

            largeCallButton(
                name: "生命热线",
                number: "400-821-1215",
                icon: "phone.fill",
                color: Color(hex: "A085C6")
            )
            .accessibilityIdentifier("crisis_hotline_life")
        }
    }

    private func largeCallButton(name: String, number: String, icon: String, color: Color) -> some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack(spacing: XuanSpacing.md) {
                CCIconMapper.image(for: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .cornerRadius(XuanRadius.sm)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(Color.xuanTextPrimary)
                        .fontWeight(.medium)
                    Text(number)
                        .font(XuanFont.h3)
                        .foregroundColor(color)
                        .fontWeight(.bold)
                }

                Spacer()

                Image("common_more")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Emergency Notice

    private var emergencyNotice: some View {
        VStack(spacing: XuanSpacing.sm) {
            Text("紧急情况请立即拨打")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)

            HStack(spacing: XuanSpacing.lg) {
                emergencyNumberLink(number: "120", label: "急救")
                    .accessibilityIdentifier("crisis_emergency_120")
                emergencyNumberLink(number: "110", label: "报警")
                    .accessibilityIdentifier("crisis_emergency_110")
            }
        }
        .padding(XuanSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.3))
        .cornerRadius(XuanRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }

    private func emergencyNumberLink(number: String, label: String) -> some View {
        Link(destination: URL(string: "tel:\(number)")!) {
            VStack(spacing: XuanSpacing.xs) {
                Text(number)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.red)
                Text(label)
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.red.opacity(0.8))
            }
            .frame(width: 100)
            .padding(.vertical, XuanSpacing.md)
            .background(Color.red.opacity(0.08))
            .cornerRadius(XuanRadius.md)
        }
    }
}
