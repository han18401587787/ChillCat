//
//  CCEmotionProfileView.swift
//  绪安 - 情绪档案 (严格对照设计稿 page_01 像素级还原)
//

import SwiftUI

struct CCEmotionProfileView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var selectedPeriod: Period = .week

    enum Period: String, CaseIterable {
        case week = "本周"
        case month = "本月"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 情绪概览头部
                overviewHeader

                // 情绪分布环形图
                distributionRing

                // 高频情绪词
                highFreqWords

                // 情绪改善趋势
                improvementTrend

                // 解锁成就
                achievements
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪档案")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 情绪概览
    private var overviewHeader: some View {
        VStack(spacing: XuanSpacing.md) {
            HStack {
                Text("情绪概览")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                Spacer()
                Picker("周期", selection: $selectedPeriod) {
                    ForEach(Period.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            HStack(spacing: XuanSpacing.lg) {
                overviewStat(value: "7", label: "记录天数", icon: "calendar", color: Color.xuanMint)
                overviewStat(value: "4", label: "情绪种类", icon: "circle.hexagongrid", color: Color.xuanApricotDark)
                overviewStat(value: "85%", label: "正向占比", icon: "arrow.up.heart", color: Color.xuanPink)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func overviewStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: XuanSpacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.xuanTextPrimary)
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 情绪分布
    private var distributionRing: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪分布")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            HStack(spacing: XuanSpacing.xl) {
                // 简易环形图
                ZStack {
                    Circle()
                        .stroke(Color.xuanSurface, lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: 0.35)
                        .stroke(Color.xuanMint, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: 0.35, to: 0.60)
                        .stroke(Color.xuanApricot, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: 0.60, to: 0.80)
                        .stroke(Color(hex: "A085C6"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: 0.80, to: 1.0)
                        .stroke(Color.xuanInfo, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("4种")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("情绪")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }

                // 图例
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    legendItem(color: Color.xuanMint, label: "平静", percent: "35%")
                    legendItem(color: Color.xuanApricot, label: "愉悦", percent: "25%")
                    legendItem(color: Color(hex: "A085C6"), label: "焦虑", percent: "20%")
                    legendItem(color: Color.xuanInfo, label: "低落", percent: "20%")
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func legendItem(color: Color, label: String, percent: String) -> some View {
        HStack(spacing: XuanSpacing.sm) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextPrimary)
            Text(percent)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
        }
    }

    // MARK: - 高频情绪词
    private var highFreqWords: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("高频情绪词")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            FlowLayout(spacing: XuanSpacing.sm) {
                wordChip("放松", color: Color.xuanMint)
                wordChip("满足", color: Color.xuanApricot)
                wordChip("期待", color: Color.xuanPink)
                wordChip("感恩", color: Color.xuanMintDark)
                wordChip("充实", color: Color.xuanApricotDark)
                wordChip("疲惫", color: Color.xuanInfo)
                wordChip("焦虑", color: Color(hex: "A085C6"))
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func wordChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(XuanFont.bodyS)
            .foregroundColor(color)
            .padding(.horizontal, XuanSpacing.md)
            .padding(.vertical, XuanSpacing.xs)
            .background(color.opacity(0.1))
            .cornerRadius(XuanRadius.full)
    }

    // MARK: - 改善趋势
    private var improvementTrend: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪改善趋势")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            Text("近4周焦虑情绪持续下降，从第1周的40%降至本周的20%。你的情绪管理能力在不断提升。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(5)

            HStack(spacing: XuanSpacing.sm) {
                ForEach(0..<4) { week in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.xuanMint, Color.xuanMintDark],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 28, height: CGFloat([60, 50, 35, 20][week]))

                        Text("W\(week+1)")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                }
            }
            .frame(height: 80)
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 成就
    private var achievements: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("解锁成就")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            HStack(spacing: XuanSpacing.md) {
                achievementBadge(icon: "flame.fill", title: "连续7天", subtitle: "坚持打卡", color: Color.xuanApricotDark, unlocked: true)
                achievementBadge(icon: "heart.fill", title: "温暖传递", subtitle: "10次共鸣", color: Color.xuanPink, unlocked: true)
                achievementBadge(icon: "brain.head.profile", title: "情绪达人", subtitle: "解码10次", color: Color(hex: "A085C6"), unlocked: true)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func achievementBadge(icon: String, title: String, subtitle: String, color: Color, unlocked: Bool) -> some View {
        VStack(spacing: XuanSpacing.sm) {
            ZStack {
                Circle()
                    .fill(unlocked ? color.opacity(0.12) : Color.xuanSurface)
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(unlocked ? color : Color.xuanTextTertiary)
            }
            Text(title)
                .font(XuanFont.caption)
                .foregroundColor(unlocked ? Color.xuanTextPrimary : Color.xuanTextTertiary)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(Color.xuanTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCEmotionProfileView()
    }
}
