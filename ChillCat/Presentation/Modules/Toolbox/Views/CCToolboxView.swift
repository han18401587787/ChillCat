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
              gradientColors: [AppTheme.info, AppTheme.calmBlue],
              route: .breathingExercise),
        .init(id: "sleep",
              name: "睡前助眠",
              description: "引导放松，安然入睡",
              sfSymbol: "moon.zzz.fill",
              gradientColors: [AppTheme.warmPurple, AppTheme.warmPurple],
              route: .meditation),
        .init(id: "solitude",
              name: "独处放松",
              description: "与自己温柔相处",
              sfSymbol: "leaf.fill",
              gradientColors: [AppTheme.accentMint, Color(hex: "A8E6CF")],
              route: .meditation),
        .init(id: "anxiety",
              name: "焦虑治愈",
              description: "放下焦虑，回归当下",
              sfSymbol: "heart.fill",
              gradientColors: [AppTheme.warmPink, Color(hex: "F2D5E0")],
              route: .meditation),
        .init(id: "cbt",
              name: "CBT认知重构",
              description: "识别并改变负面思维",
              sfSymbol: "brain.head.profile.fill",
              gradientColors: [AppTheme.warning, Color(hex: "F7C56C")],
              route: .cbtRestructuring),
        .init(id: "pmr",
              name: "渐进式肌肉放松",
              description: "释放身体紧张",
              sfSymbol: "figure.mind.and.body",
              gradientColors: [AppTheme.info, AppTheme.info.opacity(0.3)],
              route: .progressiveMuscleRelaxation),
        .init(id: "bodyscan",
              name: "正念身体扫描",
              description: "觉察身体的智慧",
              sfSymbol: "eye.fill",
              gradientColors: [AppTheme.accentMint, AppTheme.accentMint.opacity(0.2)],
              route: .bodyScan),
        .init(id: "values",
              name: "价值观探索",
              description: "找到你真正在乎的",
              sfSymbol: "compass.drawing",
              gradientColors: [AppTheme.warmPurple, AppTheme.warmPurple],
              route: .valuesExplorer),
        .init(id: "gratitude",
              name: "感恩日记",
              description: "发现生活中的美好",
              sfSymbol: "book.fill",
              gradientColors: [AppTheme.warning, AppTheme.warmGlowLight],
              route: .gratitudeJournal),
        .init(id: "ba",
              name: "行为激活",
              description: "用行动点亮心情",
              sfSymbol: "bolt.fill",
              gradientColors: [AppTheme.warmPink, AppTheme.warning],
              route: .behavioralActivation),
    ]
}

// MARK: - Toolbox View

struct CCToolboxView: View {
        @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection
                toolGrid
                bottomPadding
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("心理工具箱")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { withAnimation(.easeOut(duration: 0.4)) { appeared = true } }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("心理工具箱")
                .font(AppFont.largeTitle.weight(.bold))
                .foregroundColor(AppTheme.textPrimary)
            Text("选择一项练习，开始关爱自己")
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
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
                .accessibilityLabel("\(item.name)：\(item.description)")
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
        VStack(spacing: AppSpacing.sm) {
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
                .font(AppFont.title3)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Description
            Text(item.description)
                .font(AppFont.caption)
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            LinearGradient(
                gradient: Gradient(colors: item.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(
            color: item.gradientColors.first?.opacity(0.3) ?? .clear,
            radius: 12,
            x: 0,
            y: 4
        )
        .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: AppRadius.lg))
        .hoverEffect(.highlight)
    }

    // MARK: - Bottom Spacer

    private var bottomPadding: some View {
        Color.clear.frame(height: AppSpacing.xl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCToolboxView()}
}
