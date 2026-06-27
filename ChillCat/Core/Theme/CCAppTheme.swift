import SwiftUI

// MARK: - 绪安设计系统 Design Tokens
// 严格遵循 Ardot DesignTokens.swift — 精确浮点色值
// 最后更新：2026-06-27

// MARK: - 色彩系统 (Ardot 浮点精度)

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
    static let xuanWhite         = Color.white

    // MARK: 功能色
    static let xuanDanger        = Color(red: 0.90, green: 0.45, blue: 0.45)   // #E67373 危机红
    static let xuanWarning       = Color(red: 1.00, green: 0.72, blue: 0.30)   // #FFB84D 温和橙
    static let xuanSuccess       = Color(red: 0.51, green: 0.78, blue: 0.52)   // #82C785 成功绿
    static let xuanInfo          = Color(red: 0.39, green: 0.71, blue: 0.96)   // #63B5F5 信息蓝

    // MARK: 交互状态色
    static let xuanApricotPressed  = Color(red: 0.77, green: 0.62, blue: 0.49) // #C49E7D 暖杏按下
    static let xuanApricotDisabled = Color(red: 0.91, green: 0.77, blue: 0.64).opacity(0.4)
    static let xuanInputFocusBorder = Color(red: 0.91, green: 0.77, blue: 0.64)
    static let xuanInputErrorBorder = Color(red: 0.90, green: 0.45, blue: 0.45)
    static let xuanCardPressed      = Color(red: 0.96, green: 0.94, blue: 0.92)
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
    static let full: CGFloat = 9999
}

// MARK: - 字体系统

enum XuanFont {
    static let h1 = Font.system(size: 28, weight: .bold)
    static let h2 = Font.system(size: 22, weight: .semibold)
    static let h3 = Font.system(size: 18, weight: .medium)
    static let bodyL = Font.system(size: 16, weight: .regular)
    static let bodyM = Font.system(size: 14, weight: .regular)
    static let bodyS = Font.system(size: 12, weight: .regular)
    static let caption = Font.system(size: 11, weight: .regular)
}

// MARK: - 阴影系统

extension View {
    func xuanCardShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.06),
                    radius: 12, x: 0, y: 2)
    }
    func xuanFloatShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.10),
                    radius: 24, x: 0, y: 4)
    }
    func xuanPressShadow() -> some View {
        self.shadow(color: Color(red: 0.17, green: 0.14, blue: 0.09).opacity(0.08),
                    radius: 4, x: 0, y: 1)
    }
}

// MARK: - AppTheme 语义别名 (向后兼容 + 业务语义)

enum AppTheme {
    // 主色
    static let primary       = Color.xuanApricot
    static let primaryDark   = Color.xuanApricotDark
    static let primaryLight  = Color.xuanApricotLight
    static let primaryMuted  = Color.xuanApricot.opacity(0.6)

    // 暖色系
    static let warm          = Color.xuanApricotDark
    static let warmLight     = Color.xuanApricotLight
    static let warmMuted     = Color(hex: "F5EBDC")

    // 背景/表面
    static let background    = Color.xuanApricotBg
    static let surface       = Color.xuanSurface
    static let cardBackground = Color.xuanWhite
    static let border        = Color.xuanBorder
    static let divider       = Color.xuanDivider

    // 文字
    static let textPrimary   = Color.xuanTextPrimary
    static let textSecondary = Color.xuanTextSecondary
    static let textMuted     = Color.xuanTextTertiary
    static let textTertiary  = Color.xuanTextTertiary
    static let textInverse   = Color.white

    // 功能色
    static let success       = Color.xuanSuccess
    static let warning       = Color.xuanWarning
    static let error         = Color.xuanDanger
    static let info          = Color.xuanInfo

    // 强调色
    static let accentMint     = Color.xuanMint
    static let accentMintDark = Color.xuanMintDark
    static let accentMintLight = Color.xuanMintLight
    static let accentPink     = Color.xuanPink
    static let accentPinkDark = Color.xuanPinkDark
    static let accentPinkLight = Color.xuanPinkLight
    static let accentGold     = Color.xuanApricotDark

    // 语义化
    static let crisisRed       = Color.xuanDanger
    static let crisisRedLight  = Color(hex: "FFDAD5")
    static let crisisRedDark   = Color(hex: "C0503C")
    static let safeGreen       = Color.xuanSuccess
    static let safeGreenLight  = Color(hex: "D4EDD6")
    static let safeGreenDark   = Color(hex: "5A8A5E")
    static let warmGlow        = Color.xuanApricotDark
    static let warmGlowLight   = Color(hex: "FDF0D5")
    static let warmGlowDark    = Color(hex: "B08A3A")
    static let calmBlue        = Color.xuanInfo
    static let calmBlueLight   = Color.xuanInfo.opacity(0.2)
    static let vibrantOrange   = Color.xuanWarning
    static let hopeCyan        = Color(hex: "7CB8B0")
    static let roseGold        = Color.xuanPink
    static let roseGoldLight   = Color.xuanPink.opacity(0.2)
    static let mintGreen       = Color.xuanMint
    static let mintGreenLight  = Color.xuanMintLight
    static let warmPurple      = Color(hex: "A085C6")
    static let warmPink        = Color.xuanPink

    // 兼容旧名
    static let warmOrange   = Color.xuanApricot
    static let warmBlue     = Color.xuanInfo
    static let warmGreen    = Color.xuanSuccess
    static let warmGold     = Color.xuanApricotDark
    static let warmOrange2  = Color.xuanWarning
    static let softGreen    = Color.xuanSuccess
    static let softGreenLight = Color.xuanSuccess.opacity(0.25)
    static let softPink     = Color.xuanPink
    static let softPinkLight = Color.xuanPink.opacity(0.25)
    static let softPurple   = Color(hex: "A085C6").opacity(0.5)
    static let softPurpleLight = Color(hex: "A085C6").opacity(0.25)
    static let backgroundSecondary = Color.xuanSurface
    static let surfaceSecondary = Color.xuanSurface
    static let surfaceHover = Color.xuanBorder
    static let deepSpaceGray = Color(hex: "5A4A44")
    static let deepSpaceGrayLight = Color(hex: "F0EBE8")
    static let checkinComplete = Color.xuanSuccess
    static let checkinPending = Color.xuanTextTertiary
    static let encouragementChain = Color.xuanApricotDark
    static let alertBackground = Color(hex: "FFF0E8")
    static let alertForeground = Color.xuanDanger
    static let homeGradientStart = Color.xuanApricot
    static let homeGradientEnd = Color.xuanWarning
}

// MARK: - AppFont 别名 (兼容旧代码)

enum AppFont {
    static let largeTitle = XuanFont.h1
    static let title1     = XuanFont.h1
    static let title2     = XuanFont.h2
    static let title3     = XuanFont.h3
    static let body       = XuanFont.bodyL
    static let bodyBold   = Font.system(size: 16, weight: .semibold)
    static let buttonLabel = Font.system(size: 16, weight: .medium)
    static let caption    = XuanFont.bodyM
    static let footnote   = XuanFont.bodyS
    static let caption2   = XuanFont.caption
}

// MARK: - AppSpacing 别名

enum AppSpacing {
    static let xs   = XuanSpacing.xs
    static let sm   = XuanSpacing.sm
    static let md   = XuanSpacing.md
    static let lg   = XuanSpacing.lg
    static let xl   = XuanSpacing.xl
    static let xxl  = XuanSpacing.xl2
    static let xxxl = XuanSpacing.xl3
}

// MARK: - AppRadius 别名

enum AppRadius {
    static let xs   = XuanRadius.sm
    static let sm   = XuanRadius.sm
    static let md   = XuanRadius.md
    static let lg   = XuanRadius.lg
    static let xl   = XuanRadius.xl
    static let full = XuanRadius.full
}

// MARK: - Color hex init (仅用于 DesignTokens 中未定义的辅助色)

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
