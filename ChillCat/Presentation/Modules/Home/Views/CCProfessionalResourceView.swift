//
//  CCProfessionalResourceView.swift
//  ChillCat
//
//  专业心理资源 — 危机热线、在线咨询平台、安全计划入口
//

import SwiftUI

struct CCProfessionalResourceView: View {
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing2XL) {
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
            .padding(theme.spacingLG)
        }
        .background(theme.background)
        .navigationTitle("专业心理资源")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 36))
                .foregroundColor(theme.warm)

            Text("你不需要独自面对一切")
                .font(theme.fontH2)
                .foregroundColor(theme.textPrimary)

            Text("这里汇集了专业心理援助资源，当你需要更多支持时，请勇敢伸出手。")
                .font(theme.fontBody)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(theme.spacingXL)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
    }

    // MARK: - Hotline Section

    private var hotlineSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "phone.fill",
                title: "24小时心理援助热线",
                color: theme.softGreen
            )

            VStack(spacing: theme.spacingSM) {
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
            HStack(spacing: theme.spacingMD) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(theme.fontBody)
                        .foregroundColor(theme.textPrimary)
                    Text(number)
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.primary)
                        .fontWeight(.medium)
                }
                Spacer()
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.primary)
                    .frame(width: 36, height: 36)
                    .background(theme.primary.opacity(0.12))
                    .cornerRadius(theme.radiusSM)
            }
            .padding(theme.spacingMD)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Online Platform Section

    private var onlinePlatformSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(
                icon: "globe",
                title: "在线心理咨询平台",
                color: theme.softPurple
            )

            VStack(spacing: theme.spacingSM) {
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
        HStack(spacing: theme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.softPurple)
                .frame(width: 40, height: 40)
                .background(theme.softPurple.opacity(0.12))
                .cornerRadius(theme.radiusSM)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(theme.fontBody)
                    .foregroundColor(theme.textPrimary)
                    .fontWeight(.medium)
                Text(description)
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
            }

            Spacer()

            Image(systemName: "arrow.up.forward.app.fill")
                .font(.system(size: 14))
                .foregroundColor(theme.textMuted)
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Safety Plan Card

    private var safetyPlanCard: some View {
        NavigationLink(value: CCAppRoute.safetyPlan) {
            HStack(spacing: theme.spacingMD) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 24))
                    .foregroundColor(theme.primary)
                    .frame(width: 48, height: 48)
                    .background(theme.primary.opacity(0.12))
                    .cornerRadius(theme.radiusSM)

                VStack(alignment: .leading, spacing: 2) {
                    Text("我的安全计划")
                        .font(theme.fontBodyL)
                        .foregroundColor(theme.textPrimary)
                        .fontWeight(.medium)
                    Text("提前制定危机应对方案，在困难时刻帮助自己")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        VStack(spacing: theme.spacingSM) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 20))
                .foregroundColor(theme.warning)

            Text("绪安不是医疗产品，不能替代专业心理咨询与治疗。如果你正处于危机中，请立即拨打120或110。")
                .font(theme.fontBodyS)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacingLG)
        .frame(maxWidth: .infinity)
        .background(theme.warningLight.opacity(0.5))
        .cornerRadius(theme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radiusMD)
                .stroke(theme.warning.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: theme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(title)
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)
        }
    }
}
