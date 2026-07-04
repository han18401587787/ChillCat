//
//  CCWatcherView.swift
//  绪安 - 情绪守望者 (严格对照设计稿 page_08)
//

import SwiftUI

struct CCWatcherView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 等级卡片
                levelCard

                // 权益
                rightsSection

                // 责任
                dutiesSection

                // 升级进度
                upgradeProgress
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪守望者")
        .navigationBarTitleDisplayMode(.large)
    }

    private var levelCard: some View {
        VStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.xuanMint, Color.xuanMintDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                VStack(spacing: 0) {
                    Image("alert_guardian")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    Text("Lv.3")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text("情绪守望者")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            Text("你已经帮助了 28 位陌生人\n你的善意正在改变这个世界")
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

    private var rightsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("守望者权益")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                rightRow(icon: "heart.fill", text: "你的鼓励会被优先展示", color: Color.xuanPink)
                rightRow(icon: "star.fill", text: "获得专属「守望者」标识", color: Color.xuanApricotDark)
                rightRow(icon: "envelope.fill", text: "每月收到一封特别的感谢信", color: Color.xuanMint)
                rightRow(icon: "gift.fill", text: "解锁专属治愈内容", color: Color(hex: "A085C6"))
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func rightRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 32, height: 32)
                CCIconMapper.image(for: icon).font(.system(size: 14)).foregroundColor(color)
            }
            Text(text).font(XuanFont.bodyM).foregroundColor(Color.xuanTextPrimary)
            Spacer()
        }
    }

    private var dutiesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("守望者责任")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            Text("作为守望者，你承诺用温暖和善意回应每一位倾诉者。不评判、不说教、不否定——只是安静地在那里，让ta知道「我听到了，你并不孤单」。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(5)
        }
        .padding(XuanSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private var upgradeProgress: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("升级进度")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                HStack {
                    Text("Lv.3 → Lv.4")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text("28/50 次鼓励")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanMintDark)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.xuanSurface).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [Color.xuanMint, Color.xuanMintDark], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * 0.56, height: 8)
                    }
                }
                .frame(height: 8)

                Text("再鼓励 22 位陌生人即可升级")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }
}

#Preview { NavigationStack { CCWatcherView() } }
