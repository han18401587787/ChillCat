//
//  CCHomeView.swift
//  绪安 - 首页 (严格对照设计稿 page_18 像素级还原)
//
//  设计稿来源: /workspace/design_pages/page_18.png
//  布局从上到下：
//   顶部状态栏(日期+头像) → 问候语 → 4需求标签 → 打卡按钮 → 今日暖心 → 稳情计划 → 情绪探索 → 正在发生的温暖 → AI倾听官

import SwiftUI

struct CCHomeView: View {
    var viewModel: CCEmotionViewModel
    @Environment(CCAppCoordinator.self) private var coordinator

    // 4个需求选项 (严格对照设计稿)
    private let needItems: [NeedItem] = [
        NeedItem(title: "被倾听", subtitle: "有人愿意听你说，什么都不用解释", bgColor: Color.xuanApricotLight, selectedColor: Color.xuanApricotDark),
        NeedItem(title: "被理解", subtitle: "希望有人真的懂你在想什么", bgColor: Color.xuanMintLight, selectedColor: Color.xuanMintDark),
        NeedItem(title: "被鼓励", subtitle: "需要一些力量和温暖的肯定", bgColor: Color.xuanPinkLight, selectedColor: Color.xuanPinkDark),
        NeedItem(title: "只是想说说", subtitle: "说出来就好，不需要解决方案", bgColor: Color.xuanSurface, selectedColor: Color.xuanTextSecondary)
    ]

    struct NeedItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let bgColor: Color
        let selectedColor: Color
    }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl) {
                // 1. 顶部状态栏 (日期 + 头像)
                topStatusBar

                // 2. 问候区
                greetingSection

                // 3. 你今天想要什么? (4个需求标签)
                needSelectionCard

                // 4. 今日心情打卡按钮
                checkInButtonSection

                // 5. 今日暖心
                todayWarmthCard

                // 6. 今日稳情计划 (薄荷绿背景)
                stablePlanCard

                // 7. 情绪探索
                emotionExploreSection

                // 8. 正在发生的温暖
                warmthActivitySection

                // 9. AI倾听官入口
                aiListenerSection
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .scrollDismissesKeyboard(.interactively)
        .task { await viewModel.loadData() }
        .trackPage("Home:CCHomeView")
        .debugAction(id: "home.refresh", pageName: "Home", label: "刷新首页") {
            Task { await viewModel.loadData() }
        }
    }

    // MARK: - 1. 顶部状态栏
    private var topStatusBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()
            // 用户头像 — 点击跳转个人中心
            Button(action: {
                coordinator.navigate(to: .profile)
            }) {
                Circle()
                    .fill(Color.xuanApricot.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image("profile_user")
                            .font(.system(size: 20))
                            .foregroundColor(Color.xuanApricotDark)
                    )
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .accessibilityIdentifier("home_avatar")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }

    // MARK: - 2. 问候区
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.xs) {
            Text("早安，今天想聊聊吗？")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 3. 你今天想要什么? (4个需求标签卡片)
    private var needSelectionCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("你今天想要什么？")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.md) {
                ForEach(needItems) { item in
                    needTagButton(item)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func needTagButton(_ item: NeedItem) -> some View {
        let isSelected = viewModel.selectedNeed == item.title

        return Button(action: {
            CCHaptic.selection()
            viewModel.selectNeed(item.title)
        }) {
            Text(item.title)
                .font(XuanFont.bodyLBold)
                .foregroundColor(isSelected ? .white : Color.xuanTextPrimary)
                .frame(width: 148, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: XuanRadius.md)
                        .fill(isSelected ? item.selectedColor : item.bgColor)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityIdentifier("home_need_\(item.title)")
    }

    // MARK: - 4. 今日心情打卡按钮
    private var checkInButtonSection: some View {
        Button(action: {
            guard !viewModel.hasCheckedIn else { return }
            CCHaptic.success()
            viewModel.completeCheckIn()
            coordinator.navigate(to: .checkinSuccess)
        }) {
            HStack(spacing: XuanSpacing.sm) {
                CCIconMapper.image(for: viewModel.hasCheckedIn ? "checkmark.circle.fill" : "heart.fill")
                    .font(.system(size: 16))
                Text(viewModel.hasCheckedIn ? "今日已打卡 ✓" : "今日心情打卡")
                    .font(XuanFont.bodyLMedium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.hasCheckedIn ? Color.xuanMint : Color.xuanApricot)
            .cornerRadius(XuanRadius.lg)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .disabled(viewModel.hasCheckedIn)
        .accessibilityIdentifier("home_checkin_button")
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasCheckedIn)
    }

    // MARK: - 5. 今日暖心
    private var todayWarmthCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("今日暖心")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanPink)
                Spacer()
                Text("6.26")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text("「你已经很努力了，今天不需要证明什么。")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(4)

            HStack {
                Text("——绪安 · 情绪治愈平台")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                Spacer()
            }

            // 情绪标签
            HStack {
                Text("平静")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanMint)
                    .padding(.horizontal, XuanSpacing.md)
                    .padding(.vertical, XuanSpacing.xs)
                    .background(Color.xuanMint.opacity(0.15))
                    .cornerRadius(XuanRadius.full)
                Spacer()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 6. 今日稳情计划 (薄荷绿背景卡片)
    private var stablePlanCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("今日稳情计划")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanMintDark)
                Spacer()
                Text("第 3/7 天")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanMintDark)
            }

            Text("4-7-8 呼吸练习")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            Text("吸气4秒，屏息7秒，呼气8秒。重复5次，让焦虑随呼吸流走。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(4)
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanMintLight)
        .cornerRadius(XuanRadius.lg)
    }

    // MARK: - 7. 情绪探索
    private var emotionExploreSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪探索")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            Button(action: { coordinator.navigate(to: .emotionDecoder) }) {
                HStack(spacing: XuanSpacing.md) {
                    RoundedRectangle(cornerRadius: XuanRadius.sm)
                        .fill(Color.xuanApricot.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image("home_mood")
                                .font(.system(size: 24))
                                .foregroundColor(Color.xuanApricotDark)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("为什么焦虑总在深夜来访？")
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("从神经科学角度解读夜间焦虑的成因...")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .accessibilityIdentifier("home_emotion_explore")
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 8. 正在发生的温暖
    private var warmthActivitySection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Text("正在发生的温暖")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Spacer()
                Button(action: {
                    coordinator.navigate(to: .encourageChain)
                }) {
                    HStack(spacing: 2) {
                        Text("查看全部")
                            .font(XuanFont.bodyS)
                        Image("common_more")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color.xuanTextTertiary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("home_warmth_view_all")
            }

            VStack(spacing: XuanSpacing.md) {
                warmthActivityItem(
                    avatar: "雨",
                    avatarColor: Color.xuanInfo,
                    title: "小雨 收到了来自阿杰的鼓励",
                    subtitle: "「你的勇气，让我也敢说出自己的故事」"
                )

                warmthActivityItem(
                    avatar: "然",
                    avatarColor: Color.xuanMint,
                    title: "阿然 发起了一次鼓励接力",
                    subtitle: "「今天在地铁上看到你的文字，谢谢你」"
                )
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func warmthActivityItem(avatar: String, avatarColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(avatar)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(avatarColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextPrimary)
                Text(subtitle)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    // MARK: - 9. AI倾听官入口
    private var aiListenerSection: some View {
        Button(action: { coordinator.navigate(to: .aiListener) }) {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.xuanApricot.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Text("AI")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.xuanApricotDark)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("和绪安聊聊")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    Text("AI倾听官正在等你...")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

                Image("common_more")
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityIdentifier("home_ai_listener_entry")
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }
}

// MARK: - Preview
#Preview {
    CCHomeView(viewModel: CCEmotionViewModel())
}
