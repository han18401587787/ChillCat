//
//  CCHomeView.swift
//  绪安 - 首页 (完全对照截图 #9 像素级还原)
//
//  布局：
//   问候区 → 4需求卡片(纵向列表) → 打卡按钮 → 今日暖心 → 稳情计划 → 情绪探索
//  每个需求卡片: 左侧圆形图标 + 标题副标题 + 右侧选中指示

import SwiftUI

struct CCHomeView: View {
    @State private var viewModel = CCEmotionViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

    // 4 个需求入口 (纵向单列列表, 非网格)
    struct NeedItem: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
        let subtitle: String
        let emotion: CCEmotion
        let color: Color
    }

    private let needItems: [NeedItem] = [
        NeedItem(emoji: "👂", title: "想被倾听", subtitle: "有好多话憋在心里", emotion: .wronged, color: Color.xuanInfo),
        NeedItem(emoji: "💚", title: "需要被理解", subtitle: "感觉没有人懂我", emotion: .anxious, color: Color.xuanMint),
        NeedItem(emoji: "🔥", title: "想要一些鼓励", subtitle: "最近有点撑不住了", emotion: .calm, color: Color.xuanApricotDark),
        NeedItem(emoji: "💬", title: "就想随便说说", subtitle: "没什么大事，就是想聊聊", emotion: .happy, color: Color.xuanPink),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                if viewModel.isLoading {
                    loadingContent
                } else {
                    // 1. 问候区
                    greetingSection

                    // 2. 4个需求卡片 (纵向列表)
                    needCardList

                    // 3. 打卡按钮 (选情绪后出现)
                    if viewModel.selectedEmotion != nil && !viewModel.hasCheckedIn {
                        checkInButtonSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // 4. 已打卡庆祝
                    if viewModel.hasCheckedIn {
                        checkedInCelebration
                    }

                    // 5. 今日暖心推荐
                    todayWarmthCard

                    // 6. 稳情计划预览
                    healingPlanPreview

                    // 7. 情绪探索
                    emotionExploreSection
                }
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedEmotion)
        .task { await viewModel.loadData() }
    }

    // MARK: - Loading
    private var loadingContent: some View {
        VStack(spacing: XuanSpacing.lg) {
            greetingSection
            skeletonCard(height: 260)
            skeletonCard(height: 48)
            skeletonCard(height: 100)
            skeletonCard(height: 80)
            skeletonCard(height: 180)
        }
    }
    private func skeletonCard(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: XuanRadius.md).fill(Color.xuanSurface).frame(height: height).opacity(0.5)
    }

    // MARK: - 1. 问候区
    private var greetingSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                Text("现在是什么感受？")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.xuanTextPrimary)
                Text("已陪伴你 \(viewModel.totalDays) 天")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()

            // 连续打卡徽章
            VStack(spacing: 0) {
                Text("\(viewModel.streakDays)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.xuanApricot)
                Text("天")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .frame(width: 56, height: 56)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.md)
                    .fill(Color.xuanApricot.opacity(0.08))
            )
        }
    }

    // MARK: - 2. 需求卡片列表 (纵向, 单列)
    private var needCardList: some View {
        VStack(spacing: XuanSpacing.sm) {
            ForEach(needItems) { item in
                needCard(item)
            }
        }
    }

    private func needCard(_ item: NeedItem) -> some View {
        let isSelected = viewModel.selectedEmotion == item.emotion

        return Button(action: {
            CCHaptic.selection()
            viewModel.selectEmotion(item.emotion)
        }) {
            HStack(spacing: XuanSpacing.md) {
                // 左侧圆形图标
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? item.color.opacity(0.15)
                                : Color.xuanSurface
                        )
                        .frame(width: 48, height: 48)

                    Text(item.emoji)
                        .font(.system(size: 22))
                }

                // 标题 + 副标题
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(
                            isSelected ? Color.xuanTextPrimary : Color.xuanTextPrimary
                        )
                    Text(item.subtitle)
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Spacer()

                // 选中指示
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(item.color)
                }
            }
            .padding(XuanSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .fill(Color.xuanWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(
                        isSelected ? item.color.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: Color(hex: "2C2416").opacity(isSelected ? 0.06 : 0.03),
                radius: isSelected ? 10 : 6,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - 3. 打卡按钮
    private var checkInButtonSection: some View {
        VStack(spacing: XuanSpacing.md) {
            // 心情备注输入框
            TextField("写下此刻的感受（可选）...", text: $viewModel.todayNote, axis: .vertical)
                .font(XuanFont.bodyL)
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)
                .lineLimit(2...4)
                .xuanCardShadow()

            // 打卡按钮
            Button(action: {
                CCHaptic.success()
                viewModel.completeCheckIn()
            }) {
                HStack(spacing: XuanSpacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .medium))
                    Text("就是这样，打卡记录")
                        .font(XuanFont.bodyLMedium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.xuanApricot)
                .cornerRadius(XuanRadius.lg)
                .xuanCardShadow()
            }
        }
    }

    // MARK: - 4. 已打卡庆祝
    private var checkedInCelebration: some View {
        HStack(spacing: XuanSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.xuanMint.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.xuanMint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("今日已打卡")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Text("完成了！你真的很棒")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            Spacer()
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 5. 今日暖心
    private var todayWarmthCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(Color.xuanApricotDark)
                Text("今日暖心")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Spacer()
            }

            Button(action: {
                if !viewModel.dailyTaskCompleted {
                    CCHaptic.light()
                    viewModel.completeDailyTask()
                }
            }) {
                HStack(spacing: XuanSpacing.md) {
                    Image(systemName: viewModel.dailyTaskCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.dailyTaskCompleted ? Color.xuanMint : Color.xuanTextTertiary)

                    Text(viewModel.dailyTask)
                        .font(XuanFont.bodyL)
                        .foregroundColor(viewModel.dailyTaskCompleted ? Color.xuanTextSecondary : Color.xuanTextPrimary)
                        .strikethrough(viewModel.dailyTaskCompleted)

                    Spacer()
                }
                .padding(XuanSpacing.md)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)
            }
            .buttonStyle(.plain)
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 6. 稳情计划预览
    private var healingPlanPreview: some View {
        Button(action: { coordinator.navigate(to: .safetyPlan) }) {
            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.xuanMint)
                    Text("稳情计划")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.xuanTextTertiary)
                }

                HStack(spacing: 6) {
                    ForEach(0..<7) { day in
                        Circle()
                            .fill(day < viewModel.weeklyProgress ? Color.xuanMint : Color.xuanSurface)
                            .frame(width: 10, height: 10)
                    }
                }

                Text("本周已完成 \(viewModel.weeklyProgress)/7 天")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - 7. 情绪探索
    private var emotionExploreSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("探索更多可能")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm)
                ],
                spacing: XuanSpacing.sm
            ) {
                exploreCard(icon: "heart.fill", title: "共鸣墙", subtitle: "匿名分享心声", color: Color.xuanPink, route: .resonanceWall)
                exploreCard(icon: "leaf.fill", title: "治愈空间", subtitle: "冥想与放松", color: Color.xuanMint, route: .healing)
                exploreCard(icon: "brain.head.profile", title: "情绪解码", subtitle: "了解你的情绪", color: Color(hex: "A085C6"), route: .emotionDecoder)
                exploreCard(icon: "chart.bar.fill", title: "情绪趋势", subtitle: "查看变化轨迹", color: Color.xuanInfo, route: .trends)
            }
        }
    }

    private func exploreCard(icon: String, title: String, subtitle: String, color: Color, route: CCAppRoute) -> some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: XuanRadius.sm)
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(XuanFont.bodyLBold).foregroundColor(Color.xuanTextPrimary)
                    Text(subtitle).font(XuanFont.caption).foregroundColor(Color.xuanTextTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(XuanSpacing.md)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
        }
    }
}
