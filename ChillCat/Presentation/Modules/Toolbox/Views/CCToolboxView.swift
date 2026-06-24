//
//  CCToolboxView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//  绪安 — 心理工具箱主页
//

import SwiftUI

// MARK: - Tool Card Model

private struct CCToolItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let sfSymbol: String
    let gradientColors: [Color]
    let route: CCAppRoute

    static let all: [CCToolItem] = [
        .init(id: "breathing",
              name: "呼吸训练",
              description: "4-7-8呼吸法，快速平静",
              sfSymbol: "lungs.fill",
              gradientColors: [Color(hex: "4A90D9"), Color(hex: "6BA5E7")],
              route: .breathingExercise),
        .init(id: "sleep",
              name: "睡前助眠",
              description: "引导放松，安然入睡",
              sfSymbol: "moon.zzz.fill",
              gradientColors: [Color(hex: "7B6DA8"), Color(hex: "9B8EC4")],
              route: .meditation),
        .init(id: "solitude",
              name: "独处放松",
              description: "与自己温柔相处",
              sfSymbol: "leaf.fill",
              gradientColors: [Color(hex: "7ED3B2"), Color(hex: "A8E6CF")],
              route: .meditation),
        .init(id: "anxiety",
              name: "焦虑治愈",
              description: "放下焦虑，回归当下",
              sfSymbol: "heart.fill",
              gradientColors: [Color(hex: "E8B8C8"), Color(hex: "F2D5E0")],
              route: .meditation),
        .init(id: "cbt",
              name: "CBT认知重构",
              description: "识别并改变负面思维",
              sfSymbol: "brain.head.profile.fill",
              gradientColors: [Color(hex: "F5A623"), Color(hex: "F7C56C")],
              route: .cbtRestructuring),
        .init(id: "pmr",
              name: "渐进式肌肉放松",
              description: "释放身体紧张",
              sfSymbol: "figure.mind.and.body",
              gradientColors: [Color(hex: "4A90D9"), Color(hex: "B8D4F0")],
              route: .progressiveMuscleRelaxation),
        .init(id: "bodyscan",
              name: "正念身体扫描",
              description: "觉察身体的智慧",
              sfSymbol: "eye.fill",
              gradientColors: [Color(hex: "7ED3B2"), Color(hex: "D5F0E5")],
              route: .bodyScan),
        .init(id: "values",
              name: "价值观探索",
              description: "找到你真正在乎的",
              sfSymbol: "compass.drawing",
              gradientColors: [Color(hex: "9B8EC4"), Color(hex: "D4C8E8")],
              route: .valuesExplorer),
        .init(id: "gratitude",
              name: "感恩日记",
              description: "发现生活中的美好",
              sfSymbol: "book.fill",
              gradientColors: [Color(hex: "F5A623"), Color(hex: "FDF0D5")],
              route: .gratitudeJournal),
        .init(id: "ba",
              name: "行为激活",
              description: "用行动点亮心情",
              sfSymbol: "bolt.fill",
              gradientColors: [Color(hex: "E8B8C8"), Color(hex: "FFD700")],
              route: .behavioralActivation),
    ]
}

// MARK: - Toolbox View

struct CCToolboxView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingXL) {
                headerSection
                toolGrid
                bottomPadding
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("心理工具箱")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { withAnimation(.easeOut(duration: 0.4)) { appeared = true } }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingXS) {
            Text("心理工具箱")
                .font(theme.fontDisplay)
                .foregroundColor(theme.textPrimary)
            Text("选择一项练习，开始关爱自己")
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    // MARK: - Grid

    private var toolGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(CCToolItem.all.enumerated()), id: \.element.id) { index, item in
                NavigationLink(value: item.route) {
                    toolCard(item: item)
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(
                    .easeOut(duration: 0.4).delay(0.1 + Double(index) * 0.06),
                    value: appeared
                )
            }
        }
    }

    // MARK: - Single Card

    private func toolCard(item: CCToolItem) -> some View {
        VStack(spacing: theme.spacingSM) {
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }

            // Name
            Text(item.name)
                .font(theme.fontH3)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Description
            Text(item.description)
                .font(theme.fontCaption)
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingXL)
        .padding(.horizontal, theme.spacingSM)
        .background(
            LinearGradient(
                gradient: Gradient(colors: item.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.radiusLG))
        .shadow(
            color: item.gradientColors.first?.opacity(0.3) ?? .clear,
            radius: theme.shadowRadiusMD,
            x: 0,
            y: theme.shadowYMD
        )
        .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: theme.radiusLG))
        .hoverEffect(.highlight)
    }

    // MARK: - Bottom Spacer

    private var bottomPadding: some View {
        Color.clear.frame(height: theme.spacing2XL)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCToolboxView()
            .environment(\.ccAppTheme, CCLightTheme())
    }
}
