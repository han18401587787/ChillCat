//
//  CCMonthlyReportView.swift
//  绪安 - 月度情绪报告 (严格对照设计稿 page_05 像素级还原)
//

import SwiftUI

struct CCMonthlyReportView: View {
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 头部概览
                overviewHeader

                // 情绪波动曲线
                moodCurveCard

                // 高频情绪词云
                wordCloudCard

                // 触发场景 Top5
                triggerSceneCard

                // 改善活动 Top5
                improvementCard
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("月度报告")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 头部概览
    private var overviewHeader: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("2026年6月")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)

            HStack(spacing: XuanSpacing.xl) {
                statItem(value: "26", label: "记录天数", color: Color.xuanMint)
                statItem(value: "6", label: "情绪种类", color: Color.xuanApricotDark)
                statItem(value: "+12%", label: "正向提升", color: Color.xuanSuccess)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()
        }
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: XuanSpacing.xs) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 情绪波动曲线
    private var moodCurveCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪波动曲线")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            // 简易曲线（柱状图+连接线）
            VStack(spacing: XuanSpacing.xs) {
                ZStack {
                    // 背景网格线
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            Divider().opacity(0.3)
                            Spacer()
                        }
                    }

                    // 曲线
                    GeometryReader { geo in
                        Path { path in
                            let points = moodData.enumerated().map { i, v in
                                CGPoint(
                                    x: geo.size.width * CGFloat(i) / CGFloat(moodData.count - 1),
                                    y: geo.size.height * (1 - v / 10.0)
                                )
                            }
                            path.move(to: points[0])
                            for pt in points.dropFirst() {
                                path.addLine(to: pt)
                            }
                        }
                        .stroke(Color.xuanMint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }

                    // 数据点
                    GeometryReader { geo in
                        ForEach(Array(moodData.enumerated()), id: \.offset) { i, v in
                            Circle()
                                .fill(Color.xuanMint)
                                .frame(width: 8, height: 8)
                                .position(
                                    x: geo.size.width * CGFloat(i) / CGFloat(moodData.count - 1),
                                    y: geo.size.height * (1 - v / 10.0)
                                )
                        }
                    }
                }
                .frame(height: 160)

                // X轴标签
                HStack(spacing: 0) {
                    ForEach(["6/1", "6/5", "6/10", "6/15", "6/20", "6/25", "6/30"], id: \.self) { label in
                        Text(label)
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private let moodData: [Double] = [6, 7, 8, 5, 4, 6, 7, 9, 8, 6, 7, 8, 5, 4, 6, 7, 8, 7, 9, 8, 7, 6, 5, 7, 8, 9, 7, 6, 7, 8]

    // MARK: - 高频情绪词云
    private var wordCloudCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("高频情绪词云")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            FlowLayout(spacing: XuanSpacing.sm) {
                wordBubble("平静", size: 20, color: Color.xuanMint)
                wordBubble("满足", size: 18, color: Color.xuanApricot)
                wordBubble("感恩", size: 16, color: Color.xuanPink)
                wordBubble("充实", size: 14, color: Color.xuanMintDark)
                wordBubble("焦虑", size: 13, color: Color(hex: "A085C6"))
                wordBubble("期待", size: 12, color: Color.xuanApricotDark)
                wordBubble("疲惫", size: 11, color: Color.xuanInfo)
                wordBubble("放松", size: 11, color: Color.xuanMint)
                wordBubble("幸福", size: 10, color: Color.xuanPink)
                wordBubble("思念", size: 10, color: Color(hex: "A085C6"))
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func wordBubble(_ text: String, size: CGFloat, color: Color) -> some View {
        Text(text)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, XuanSpacing.sm)
            .padding(.vertical, XuanSpacing.xs)
            .background(color.opacity(0.08))
            .cornerRadius(XuanRadius.full)
    }

    // MARK: - 触发场景 Top5
    private var triggerSceneCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("触发场景 Top5")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                triggerRow(rank: 1, scene: "工作压力/截止日期", count: 8, color: Color.xuanDanger)
                triggerRow(rank: 2, scene: "人际关系冲突", count: 5, color: Color.xuanWarning)
                triggerRow(rank: 3, scene: "睡眠不足", count: 4, color: Color(hex: "A085C6"))
                triggerRow(rank: 4, scene: "社交媒体的负面信息", count: 3, color: Color.xuanInfo)
                triggerRow(rank: 5, scene: "天气变化/阴雨天", count: 2, color: Color.xuanTextTertiary)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func triggerRow(rank: Int, scene: String, count: Int, color: Color) -> some View {
        HStack(spacing: XuanSpacing.md) {
            Text("\(rank)")
                .font(XuanFont.bodyS)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(color)
                .cornerRadius(XuanRadius.sm)

            Text(scene)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()

            Text("\(count)次")
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
    }

    // MARK: - 改善活动 Top5
    private var improvementCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("改善活动 Top5")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.sm) {
                improveRow(rank: 1, activity: "户外散步/接触自然", effectiveness: "85%", color: Color.xuanMint)
                improveRow(rank: 2, activity: "与朋友聊天", effectiveness: "78%", color: Color.xuanApricot)
                improveRow(rank: 3, activity: "听音乐/播客", effectiveness: "72%", color: Color.xuanPink)
                improveRow(rank: 4, activity: "冥想/深呼吸练习", effectiveness: "68%", color: Color(hex: "A085C6"))
                improveRow(rank: 5, activity: "写日记/记录感受", effectiveness: "60%", color: Color.xuanInfo)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func improveRow(rank: Int, activity: String, effectiveness: String, color: Color) -> some View {
        HStack(spacing: XuanSpacing.md) {
            Text("\(rank)")
                .font(XuanFont.bodyS)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(color)
                .cornerRadius(XuanRadius.sm)

            Text(activity)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()

            Text(effectiveness)
                .font(XuanFont.caption)
                .foregroundColor(color)
                .padding(.horizontal, XuanSpacing.sm)
                .padding(.vertical, 2)
                .background(color.opacity(0.1))
                .cornerRadius(XuanRadius.full)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCMonthlyReportView()
    }
}
