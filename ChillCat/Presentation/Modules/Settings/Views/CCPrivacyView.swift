//
//  CCPrivacyView.swift
//  绪安 - 隐私保护承诺 (严格对照设计稿 page_12)
//

import SwiftUI

struct CCPrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                headerSection

                VStack(spacing: XuanSpacing.md) {
                    privacyItem(icon: "lock.shield.fill", title: "数据加密存储", desc: "所有你的情绪数据都经过AES-256加密后存储，即使服务端也无法直接读取明文内容。", color: Color.xuanMint)
                        .accessibilityIdentifier("privacy_encryption")
                    privacyItem(icon: "eye.slash.fill", title: "匿名保护", desc: "你的身份信息与情绪数据完全隔离。在共鸣墙上发布的内容默认匿名，没有人知道你是谁。", color: Color.xuanInfo)
                        .accessibilityIdentifier("privacy_anonymous")
                    privacyItem(icon: "trash.fill", title: "数据删除权利", desc: "你可以随时在「设置-数据管理」中一键删除所有数据。删除后数据不可恢复。", color: Color.xuanDanger)
                        .accessibilityIdentifier("privacy_data_deletion")
                    privacyItem(icon: "hand.raised.fill", title: "不出售数据", desc: "我们承诺永远不出售、不分享你的个人数据给任何第三方。你的隐私是我们的底线。", color: Color.xuanApricotDark)
                        .accessibilityIdentifier("privacy_no_sale")
                }
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("隐私保护")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerSection: some View {
        VStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.xuanMint.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image("profile_privacy")
                    .font(.system(size: 36))
                    .foregroundColor(Color.xuanMint)
            }

            Text("你的隐私，我们的责任")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            Text("绪安将你的数据安全放在首位。\n以下是我们的隐私保护承诺。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(XuanSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func privacyItem(icon: String, title: String, desc: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: XuanSpacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: XuanRadius.md)
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                CCIconMapper.image(for: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)
                Text(desc)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }
}

#Preview { NavigationStack { CCPrivacyView() } }
