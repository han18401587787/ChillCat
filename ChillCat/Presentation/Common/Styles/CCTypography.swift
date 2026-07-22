//
//  CCTypography.swift
//  ChillCat
//
//  Created by CodeBuddy on 2026/6/18.
//  绪安v3.0 排版系统 (PRD: PingFang SC 字阶)
//

import SwiftUI

// MARK: - 排版修饰器

struct CCXuanDisplay: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.h1)
    }
}

struct CCXuanH1: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.h1)
    }
}

struct CCXuanH2: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.h1)
    }
}

struct CCXuanH3: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.h3)
    }
}

struct CCXuanBodyL: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.bodyLMedium)
    }
}

struct CCXuanBody: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.bodyL)
    }
}

struct CCXuanBodyS: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.bodyS)
    }
}

struct CCXuanCaption: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.bodyM)
    }
}

struct CCXuanLabel: ViewModifier {
    func body(content: Content) -> some View {
        content.font(XuanFont.bodyM)
    }
}

// MARK: - View Extension

extension View {
    /// Display 32px Bold — 页面主标题
    func xuanDisplay() -> some View {
        modifier(CCXuanDisplay())
    }

    /// H1 24px Semibold — 页面标题
    func xuanH1() -> some View {
        modifier(CCXuanH1())
    }

    /// H2 20px Semibold — 模块标题
    func xuanH2() -> some View {
        modifier(CCXuanH2())
    }

    /// H3 18px Medium — 小节标题
    func xuanH3() -> some View {
        modifier(CCXuanH3())
    }

    /// BodyL 16px Regular — 大正文
    func xuanBodyL() -> some View {
        modifier(CCXuanBodyL())
    }

    /// Body 14px Regular — 正文（默认）
    func xuanBody() -> some View {
        modifier(CCXuanBody())
    }

    /// BodyS 13px Regular — 辅助正文
    func xuanBodyS() -> some View {
        modifier(CCXuanBodyS())
    }

    /// Caption 12px Regular — 说明文字
    func xuanCaption() -> some View {
        modifier(CCXuanCaption())
    }

    /// Label 11px Medium — 标签/徽章
    func xuanLabel() -> some View {
        modifier(CCXuanLabel())
    }
}
