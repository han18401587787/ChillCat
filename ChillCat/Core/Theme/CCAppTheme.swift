//
//  CCAppTheme.swift
//  ChillCat
//
//  Created by doudou.han on 2026-06-27.
//
//  完全遵循 DesignTokens.swift — 绪安设计系统唯一权威来源
//  来源: /Users/handou/Downloads/xuan-download/绪安设计标注资源包/DesignTokens.swift

import SwiftUI

// MARK: - 色彩系统

extension Color {
    
    // MARK: 主色
    static let xuanApricot       = Color(red: 0.91, green: 0.77, blue: 0.64)   // #E8C4A3 暖杏主色
    static let xuanApricotDark   = Color(red: 0.83, green: 0.66, blue: 0.51)   // #D4A882 深暖杏
    static let xuanApricotLight  = Color(red: 0.95, green: 0.86, blue: 0.79)   // #F2DBC9 浅暖杏
    static let xuanApricotBg     = Color(red: 0.98, green: 0.95, blue: 0.93)   // #FAF3ED 杏白背景
    
    // MARK: 薄荷绿
    static let xuanMint          = Color(red: 0.66, green: 0.85, blue: 0.73)   // #A8D9BA 薄荷绿
    static let xuanMintDark      = Color(red: 0.48, green: 0.75, blue: 0.62)   // #7ABF9E 深薄荷
    static let xuanMintLight     = Color(red: 0.84, green: 0.94, blue: 0.88)   // #D6F0E0 浅薄荷
    
    // MARK: 樱花粉
    static let xuanPink          = Color(red: 0.96, green: 0.65, blue: 0.73)   // #F5A6BA 樱花粉
    static let xuanPinkDark      = Color(red: 0.91, green: 0.53, blue: 0.61)   // #E8879C 深樱花
    static let xuanPinkLight     = Color(red: 0.99, green: 0.89, blue: 0.93)   // #FCE3ED 浅樱花
    
    // MARK: 文字色
    static let xuanTextPrimary   = Color(red: 0.17, green: 0.14, blue: 0.09)   // #2C2416 深棕文字
    static let xuanTextSecondary = Color(red: 0.36, green: 0.31, blue: 0.23)   // #5C4F3A 中棕文字
    static let xuanTextTertiary  = Color(red: 0.55, green: 0.49, blue: 0.43)   // #8C7D6E 浅棕文字
    
    // MARK: 中性色
    static let xuanDivider       = Color(red: 0.75, green: 0.71, blue: 0.66)   // #BFB5A8 灰棕分割
    static let xuanBorder        = Color(red: 0.91, green: 0.89, blue: 0.85)   // #E8E3D9 暖灰边框
    static let xuanSurface       = Color(red: 0.96, green: 0.94, blue: 0.92)   // #F5F0EB 暖白底色
    static let xuanWhite         = Color.white                                  // #FFFFFF 纯白
    
    // MARK: 功能色
    static let xuanDanger        = Color(red: 0.90, green: 0.45, blue: 0.45)   // #E67373 危机红
    static let xuanWarning       = Color(red: 1.00, green: 0.72, blue: 0.30)   // #FFB84D 温和橙
    static let xuanSuccess       = Color(red: 0.51, green: 0.78, blue: 0.52)   // #82C785 成功绿
    static let xuanInfo          = Color(red: 0.39, green: 0.71, blue: 0.96)   // #63B5F5 信息蓝
    
    // MARK: 交互状态色
    static let xuanApricotPressed  = Color(red: 0.77, green: 0.62, blue: 0.49) // #C49E7D 暖杏按下
    static let xuanApricotDisabled = Color(red: 0.91, green: 0.77, blue: 0.64).opacity(0.4) // 暖杏禁用
    static let xuanInputFocusBorder = Color(red: 0.91, green: 0.77, blue: 0.64) // 输入框聚焦描边
    static let xuanInputErrorBorder = Color(red: 0.90, green: 0.45, blue: 0.45) // 输入框错误描边
    static let xuanInputDisabledBg  = Color(red: 0.96, green: 0.94, blue: 0.92).opacity(0.5) // 输入框禁用背景
    static let xuanCardPressed      = Color(red: 0.96, green: 0.94, blue: 0.92) // 卡片按下背景
}


// MARK: - 间距系统

enum XuanSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xl2: CGFloat = 24
    static let xl3: CGFloat = 32
}


// MARK: - 圆角系统

enum XuanRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let full: CGFloat = 9999  // 胶囊形
}


// MARK: - 字体系统

enum XuanFont {
    /// 28pt - 大标题
    static let h1 = Font.system(size: 28, weight: .bold)
    /// 22pt - 标题
    static let h2 = Font.system(size: 22, weight: .semibold)
    /// 18pt - 小标题
    static let h3 = Font.system(size: 18, weight: .medium)
    /// 16pt - 正文大
    static let bodyL = Font.system(size: 16, weight: .regular)
    /// 14pt - 正文中
    static let bodyM = Font.system(size: 14, weight: .regular)
    /// 12pt - 正文小
    static let bodyS = Font.system(size: 12, weight: .regular)
    /// 11pt - 注释
    static let caption = Font.system(size: 11, weight: .regular)
    
    // PingFang SC 版本（如果需要指定字体族）
    static let h1PF = Font.custom("PingFang SC", size: 28).weight(.bold)
    static let h2PF = Font.custom("PingFang SC", size: 22).weight(.semibold)
    static let h3PF = Font.custom("PingFang SC", size: 18).weight(.medium)
    static let bodyLPF = Font.custom("PingFang SC", size: 16)
    static let bodyMPF = Font.custom("PingFang SC", size: 14)
    static let bodySPF = Font.custom("PingFang SC", size: 12)
    static let captionPF = Font.custom("PingFang SC", size: 11)
}


// MARK: - 阴影系统

extension View {
    /// 卡片阴影 — 日常状态
    func xuanCardShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.06),
                    radius: 12, x: 0, y: 2)
    }
    
    /// 浮层阴影 — 弹窗/浮动元素
    func xuanFloatShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.10),
                    radius: 24, x: 0, y: 4)
    }
    
    /// 按压阴影 — Pressed 态
    func xuanPressShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.08),
                    radius: 4, x: 0, y: 1)
    }
}


// MARK: - XuanFont 常用变体扩展

extension XuanFont {
    /// 16pt - 正文大·加粗
    static let bodyLBold = Font.system(size: 16, weight: .semibold)
    /// 16pt - 正文大·中粗
    static let bodyLMedium = Font.system(size: 16, weight: .medium)
}


// MARK: - Color hex init (DesignTokens 中未覆盖的辅助色)

extension Color {
    init(hex: String) {
        let r, g, b: Double
        let start = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let scanner = Scanner(string: start)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        r = Double((hexNumber & 0xFF0000) >> 16) / 255
        g = Double((hexNumber & 0x00FF00) >> 8) / 255
        b = Double(hexNumber & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
