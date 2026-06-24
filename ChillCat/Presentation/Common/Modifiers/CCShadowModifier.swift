//
//  CCShadowModifier.swift
//  ChillCat
//
//  Created by CodeBuddy on 2026/6/18.
//  绪安v3.0 蓝调柔影系统
//

import SwiftUI

// MARK: - 柔和阴影

struct CCXuanShadowSM: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: theme.shadowColor.opacity(theme.shadowOpacitySM),
            radius: theme.shadowRadiusSM,
            y: theme.shadowYSM
        )
    }
}

struct CCXuanShadowMD: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: theme.shadowColor.opacity(theme.shadowOpacityMD),
            radius: theme.shadowRadiusMD,
            y: theme.shadowYMD
        )
    }
}

struct CCXuanShadowLG: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: theme.shadowColor.opacity(theme.shadowOpacityLG),
            radius: theme.shadowRadiusLG,
            y: theme.shadowYLG
        )
    }
}

// MARK: - 卡片悬浮阴影（带微上移）

struct CCXuanCardShadow: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: theme.shadowColor.opacity(theme.shadowOpacityMD),
            radius: theme.shadowRadiusMD,
            y: theme.shadowYMD
        )
    }
}

struct CCXuanCardHoverShadow: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: theme.shadowColor.opacity(theme.shadowOpacityLG),
            radius: theme.shadowRadiusLG,
            y: theme.shadowYLG
        )
        .offset(y: -2)
    }
}

// MARK: - 底部导航栏阴影

struct CCXuanBottomShadow: ViewModifier {
    @Environment(\.ccAppTheme) private var theme
    func body(content: Content) -> some View {
        content.shadow(
            color: Color.black.opacity(0.06),
            radius: 4,
            y: -2
        )
    }
}

// MARK: - View Extension

extension View {
    /// 小阴影 — 卡片默认状态
    func xuanShadowSM() -> some View {
        modifier(CCXuanShadowSM())
    }

    /// 中阴影 — 卡片悬浮状态
    func xuanShadowMD() -> some View {
        modifier(CCXuanShadowMD())
    }

    /// 大阴影 — 弹窗/浮层
    func xuanShadowLG() -> some View {
        modifier(CCXuanShadowLG())
    }

    /// 卡片默认阴影
    func xuanCardShadow() -> some View {
        modifier(CCXuanCardShadow())
    }

    /// 卡片悬浮阴影（带微上移）
    func xuanCardHoverShadow() -> some View {
        modifier(CCXuanCardHoverShadow())
    }

    /// 底部固定栏阴影
    func xuanBottomShadow() -> some View {
        modifier(CCXuanBottomShadow())
    }
}
