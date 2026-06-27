//
//  CCProfessionalResourceView.swift
//  ChillCat
//
//  专业心理资源 — 危机热线、在线咨询平台、安全计划入口
//

import SwiftUI

struct CCProfessionalResourceView: View {
        @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // MARK: - 头部说明
                headerSection

                // MARK: - 24小时心理援助热线
                hotlineSection

                // MARK: - 在线心理咨询平台
                onlinePlatformSection

                // MARK: - 安全计划入口
                safetyPlanCard

                // MARK: - 免责声明
                disclaimerSection
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("专业心理资源")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.warmGold)

            Text("你不需要独自面对一切")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)

            Text("这里汇集了专业心理援助资源，当你需要更多支持时，请勇敢伸出手。")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Hotline Section

    private var hotlineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "phone.fill",
                title: "24小时心理援助热线",
                color: AppTheme.accentMint
            )

            VStack(spacing: AppSpacing.sm) {
                hotlineRow(
                    name: "全国24小时心理援助热线",
                    number: "400-161-9995"
                )
                hotlineRow(
                    name: "北京心理危机研究与干预中心",
                    number: "010-82951332"
                )
                hotlineRow(
                    name: "生命热线",
                    number: "400-821-1215"
                )
                hotlineRow(
                    name: "希望24热线",
                    number: "400-161-9995"
                )
            }
        }
    }

    private func hotlineRow(name: String, number: String) -> some View {
        Link(destination: URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))")!) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(number)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.primary)
                        .fontWeight(.medium)
                }
                Spacer()
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(AppRadius.sm)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Online Platform Section

    private var onlinePlatformSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(
                icon: "globe",
                title: "在线心理咨询平台",
                color: AppTheme.warmPurple
            )

            VStack(spacing: AppSpacing.sm) {
                platformRow(
                    name: "壹心理",
                    description: "专业心理咨询师在线预约",
                    icon: "person.2.fill"
                )
                platformRow(
                    name: "简单心理",
                    description: "寻找适合你的心理咨询师",
                    icon: "heart.circle.fill"
                )
                platformRow(
                    name: "知我心理",
                    description: "心理健康科普与咨询",
                    icon: "brain.head.profile"
                )
            }
        }
    }

    private func platformRow(name: String, description: String, icon: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.warmPurple)
                .frame(width: 40, height: 40)
                .background(AppTheme.warmPurple.opacity(0.12))
                .cornerRadius(AppRadius.sm)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.medium)
                Text(description)
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "arrow.up.forward.app.fill")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Safety Plan Card

    private var safetyPlanCard: some View {
        NavigationLink(value: CCAppRoute.safetyPlan) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(AppRadius.sm)

                VStack(alignment: .leading, spacing: 2) {
                    Text("我的安全计划")
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.medium)
                    Text("提前制定危机应对方案，在困难时刻帮助自己")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.orange)

            Text("绪安不是医疗产品，不能替代专业心理咨询与治疗。如果你正处于危机中，请立即拨打120或110。")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(title)
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
