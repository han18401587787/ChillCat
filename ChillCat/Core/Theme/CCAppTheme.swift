import SwiftUI

// MARK: - CCAppTheme 绪安设计系统 (Ardot v3)
/// 设计数据源：Ardot 设计标注资源包 DesignTokens.swift
/// 使用方式：AppTheme.primary / AppTheme.accent / AppSpacing.sm / AppRadius.md
///
/// 旧设计系统已于 2026/06/27 废弃，全量替换为 Ardot 精确色值。

// MARK: - 每日主题色

enum DayTheme: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var name: String {
        switch self {
        case .monday:    return "希望杏"
        case .tuesday:   return "勇气蓝"
        case .wednesday: return "治愈绿"
        case .thursday:  return "温暖金"
        case .friday:    return "喜悦橙"
        case .saturday:  return "宁静紫"
        case .sunday:    return "温柔粉"
        }
    }

    var primary: Color {
        switch self {
        case .monday:    return AppTheme.warmOrange
        case .tuesday:   return AppTheme.warmBlue
        case .wednesday: return AppTheme.warmGreen
        case .thursday:  return AppTheme.warmGold
        case .friday:    return AppTheme.warmOrange2
        case .saturday:  return AppTheme.warmPurple
        case .sunday:    return AppTheme.warmPink
        }
    }

    var subtitle: String {
        switch self {
        case .monday:    return "新的一周，从希望开始"
        case .tuesday:   return "勇气是温柔的力量"
        case .wednesday: return "治愈自己，也治愈世界"
        case .thursday:  return "每一天都闪闪发光"
        case .friday:    return "喜悦是最好的礼物"
        case .saturday:  return "宁静是给自己的温柔"
        case .sunday:    return "被温柔包裹的一天"
        }
    }

    /// 根据 Foundation Calendar API 自动计算当天主题
    static var current: DayTheme {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return DayTheme(rawValue: weekday) ?? .monday
    }
}

// MARK: - 字体语义化 Token (Ardot 规范)

enum FontToken {
    /// 主问候语/大标题 28pt Bold — Ardot H1
    case greetingTitle
    /// 页面/区块标题 22pt Semibold — Ardot H2
    case sectionTitle
    /// 小标题 18pt Medium — Ardot H3
    case h3
    /// 正文/对话 16pt Regular — Ardot Body-L, lineHeight 1.65
    case bodyComfortable
    /// 长文/情绪日记 15pt Regular, lineHeight 1.7
    case journalText
    /// 大数字 Semibold
    case numberWarm(CGFloat)
    /// 按钮文字 16pt Medium
    case buttonLabel
    /// 辅助说明 12pt Regular — Ardot Body-S
    case caption

    var font: Font {
        switch self {
        case .greetingTitle:
            return .system(size: 28, weight: .bold, design: .default)
        case .sectionTitle:
            return .system(size: 22, weight: .semibold, design: .default)
        case .h3:
            return .system(size: 18, weight: .medium, design: .default)
        case .bodyComfortable:
            return .system(size: 16, weight: .regular, design: .default)
        case .journalText:
            return .system(size: 15, weight: .regular, design: .default)
        case .numberWarm(let size):
            return .system(size: size, weight: .semibold, design: .default)
        case .buttonLabel:
            return .system(size: 16, weight: .medium, design: .default)
        case .caption:
            return .system(size: 12, weight: .regular, design: .default)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .greetingTitle:  return 0
        case .sectionTitle:   return 0
        case .h3:             return 0
        case .bodyComfortable: return 16 * 0.65
        case .journalText:     return 15 * 0.70
        case .numberWarm:      return 0
        case .buttonLabel:     return 0
        case .caption:         return 0
        }
    }
}

// MARK: - AppTheme 颜色系统 (Ardot 精确值)

enum AppTheme {
    // MARK: - v3 暖色系基础色 (Ardot)

    static let warmOrange  = Color(hex: "E8C4A3")   // 暖杏主色 (Ardot xuanApricot)
    static let warmBlue    = Color(hex: "63B5F5")   // 信息蓝 (Ardot xuanInfo)
    static let warmGreen   = Color(hex: "82C785")   // 成功绿 (Ardot xuanSuccess)
    static let warmGold    = Color(hex: "D4A882")   // 深暖杏 (Ardot xuanApricotDark)
    static let warmOrange2 = Color(hex: "FFB84D")   // 温和橙 (Ardot xuanWarning)
    static let warmPurple  = Color(hex: "A085C6")   // 保留
    static let warmPink    = Color(hex: "F5A6BA")   // 樱花粉 (Ardot xuanPink)

    // MARK: - 背景/表面 (Ardot 杏白系)

    static let background   = Color(hex: "FAF3ED")  // 杏白背景 (Ardot xuanApricotBg)
    static let surface      = Color(hex: "F5F0EB")  // 暖白底色 (Ardot xuanSurface)
    static let surfaceHover = Color(hex: "E8E3D9")  // 暖灰悬停

    // MARK: - 文字 (Ardot 深棕系)

    static let textPrimary   = Color(hex: "2C2416")  // 深棕文字 (Ardot xuanTextPrimary)
    static let textSecondary = Color(hex: "5C4F3A")  // 中棕文字 (Ardot xuanTextSecondary)
    static let textMuted     = Color(hex: "8C7D6E")  // 浅棕文字 (Ardot xuanTextTertiary)

    // MARK: - 功能色 (Ardot)

    static let success = Color(hex: "82C785")  // 成功绿 (Ardot xuanSuccess)
    static let warning = Color(hex: "FFB84D")  // 温和橙 (Ardot xuanWarning)
    static let error   = Color(hex: "E67373")  // 危机红 (Ardot xuanDanger)
    static let info    = Color(hex: "63B5F5")  // 信息蓝 (Ardot xuanInfo)

    // MARK: - 强调色 (Ardot 次要色板)

    static let accentGreen = Color(hex: "82C785")
    static let accentPink  = Color(hex: "F5A6BA")
    static let accentGold  = Color(hex: "D4A882")
    /// Ardot 薄荷绿 (xuanMint)
    static let accentMint  = Color(hex: "A8D9BA")
    static let accentMintDark = Color(hex: "7ABF9E")

    // MARK: - 动态主色（每日主题）

    /// 根据当天星期自动切换主色
    static var accent: Color { DayTheme.current.primary }

    // MARK: - 语义化颜色

    static let homeGradientStart = warmOrange
    static let homeGradientEnd   = warmOrange2
    static let alertBackground   = Color(hex: "FFF0E8")
    static let alertForeground   = error
    static let checkinComplete   = success
    static let checkinPending    = textMuted
    static let encouragementChain = warmGold

    // MARK: - v2 兼容别名（全部保留，确保旧引用不报错）

    /// v2: primary → warmOrange
    static let primary = warmOrange
    /// v2: primaryLight → warmBlue
    static let primaryLight = warmBlue
    /// v2: primaryDark
    static let primaryDark = Color(hex: "C49E7D")
    /// v2: primaryMuted
    static let primaryMuted = warmOrange.opacity(0.6)

    /// v2: warm → warmGold
    static let warm = warmGold
    /// v2: warmLight
    static let warmLight = Color(hex: "F2DBC9")
    /// v2: warmMuted
    static let warmMuted = Color(hex: "F5EBDC")

    /// v2: softPurple
    static let softPurple = warmPurple.opacity(0.5)
    /// v2: softPurpleLight
    static let softPurpleLight = warmPurple.opacity(0.25)
    /// v2: softGreen
    static let softGreen = warmGreen
    /// v2: softGreenLight
    static let softGreenLight = warmGreen.opacity(0.25)
    /// v2: softPink
    static let softPink = warmPink
    /// v2: softPinkLight
    static let softPinkLight = warmPink.opacity(0.25)

    /// v2: background → surface 别名
    static let backgroundSecondary = surface
    /// v2: surface
    static let surfaceSecondary = surface
    /// v2: cardBackground
    static let cardBackground = Color.white

    /// v2: textTertiary → textMuted
    static let textTertiary = textMuted
    /// v2: textInverse
    static let textInverse = Color.white

    /// v2: border
    static let border = Color(hex: "E8E3D9")
    /// v2: divider
    static let divider = Color(hex: "BFB5A8")

    // MARK: - v3 语义化颜色 Token (Ardot)

    /// 危机红 - 用于紧急状态/高危提示
    static let crisisRed = error
    static let crisisRedLight = Color(hex: "FFDAD5")
    static let crisisRedDark = Color(hex: "C0503C")

    /// 安全绿 - 用于稳定状态/安全标识
    static let safeGreen = success
    static let safeGreenLight = Color(hex: "D4EDD6")
    static let safeGreenDark = Color(hex: "5A8A5E")

    /// 暖光 - 用于温暖提示/鼓励
    static let warmGlow = warmGold
    static let warmGlowLight = Color(hex: "FDF0D5")
    static let warmGlowDark = Color(hex: "B08A3A")

    /// 宁静蓝 - 用于睡眠/平静场景
    static let calmBlue = warmBlue
    static let calmBlueLight = warmBlue.opacity(0.2)

    /// 活力橙 - 用于激励/提醒
    static let vibrantOrange = warmOrange2
    static let vibrantOrangeLight = warmOrange2.opacity(0.2)

    /// 希望青 - 用于成长/进步
    static let hopeCyan = Color(hex: "7CB8B0")
    static let hopeCyanLight = hopeCyan.opacity(0.2)

    /// 深空灰 - 用于高级感卡片背景
    static let deepSpaceGray = Color(hex: "5A4A44")
    static let deepSpaceGrayLight = Color(hex: "F0EBE8")

    /// 玫瑰金 - 用于温柔强调
    static let roseGold = warmPink
    static let roseGoldLight = warmPink.opacity(0.2)

    /// 薄荷绿 - 用于清新/新生 (Ardot xuanMint)
    static let mintGreen = Color(hex: "A8D9BA")
    static let mintGreenLight = Color(hex: "D6F0E0")
}

// MARK: - Color Extension

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

// MARK: - CCAppThemeProtocol（v2 兼容，快照测试使用）

protocol CCAppThemeProtocol {
    var primary: Color { get }
    var primaryLight: Color { get }
    var primaryMuted: Color { get }
    var warm: Color { get }
    var warmLight: Color { get }
    var softPurple: Color { get }
    var softPurpleLight: Color { get }
    var softGreen: Color { get }
    var softGreenLight: Color { get }
    var softPink: Color { get }
    var softPinkLight: Color { get }
    var warmMuted: Color { get }
    var background: Color { get }
    var surface: Color { get }
    var cardBackground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textMuted: Color { get }
    var error: Color { get }
    var success: Color { get }
    var spacingXS: CGFloat { get }
    var spacingSM: CGFloat { get }
    var spacingMD: CGFloat { get }
    var spacingLG: CGFloat { get }
    var spacingXL: CGFloat { get }
    var radiusSM: CGFloat { get }
    var radiusMD: CGFloat { get }
    var radiusLG: CGFloat { get }
    var radiusXL: CGFloat { get }
}

// MARK: - 亮色主题（快照测试兼容 - Ardot 值）

struct CCLightTheme: CCAppThemeProtocol {
    let primary = Color(hex: "E8C4A3")
    let primaryLight = Color(hex: "63B5F5")
    let primaryMuted = Color(hex: "E8C4A3").opacity(0.6)
    let warm = Color(hex: "D4A882")
    let warmLight = Color(hex: "F2DBC9")
    let softPurple = Color(hex: "A085C6").opacity(0.5)
    let softPurpleLight = Color(hex: "A085C6").opacity(0.25)
    let softGreen = Color(hex: "82C785")
    let softGreenLight = Color(hex: "82C785").opacity(0.25)
    let softPink = Color(hex: "F5A6BA")
    let softPinkLight = Color(hex: "F5A6BA").opacity(0.25)
    let warmMuted = Color(hex: "F5EBDC")
    let background = Color(hex: "FAF3ED")
    let surface = Color(hex: "F5F0EB")
    let cardBackground = Color.white
    let textPrimary = Color(hex: "2C2416")
    let textSecondary = Color(hex: "5C4F3A")
    let textMuted = Color(hex: "8C7D6E")
    let error = Color(hex: "E67373")
    let success = Color(hex: "82C785")
    let spacingXS: CGFloat = 4
    let spacingSM: CGFloat = 8
    let spacingMD: CGFloat = 12
    let spacingLG: CGFloat = 16
    let spacingXL: CGFloat = 20
    let radiusSM: CGFloat = 8
    let radiusMD: CGFloat = 12
    let radiusLG: CGFloat = 16
    let radiusXL: CGFloat = 20
}

// MARK: - 暗色主题（快照测试兼容 - Ardot 暗色映射）

struct CCDarkTheme: CCAppThemeProtocol {
    let primary = Color(hex: "D4A882")
    let primaryLight = Color(hex: "5A9FD4")
    let primaryMuted = Color(hex: "8B6F5A")
    let warm = Color(hex: "B8956A")
    let warmLight = Color(hex: "8B6F47")
    let softPurple = Color(hex: "8B7DA8")
    let softPurpleLight = Color(hex: "5B4D78")
    let softGreen = Color(hex: "6BA870")
    let softGreenLight = Color(hex: "3D6040")
    let softPink = Color(hex: "C890A0")
    let softPinkLight = Color(hex: "A87888")
    let warmMuted = Color(hex: "3D3528")
    let background = Color(hex: "1A1D1F")
    let surface = Color(hex: "242729")
    let cardBackground = Color(hex: "2D3033")
    let textPrimary = Color(hex: "E8E8E8")
    let textSecondary = Color(hex: "999999")
    let textMuted = Color(hex: "666666")
    let error = Color(hex: "E67373")
    let success = Color(hex: "82C785")
    let spacingXS: CGFloat = 4
    let spacingSM: CGFloat = 8
    let spacingMD: CGFloat = 12
    let spacingLG: CGFloat = 16
    let spacingXL: CGFloat = 20
    let radiusSM: CGFloat = 8
    let radiusMD: CGFloat = 12
    let radiusLG: CGFloat = 16
    let radiusXL: CGFloat = 20
}

// MARK: - Environment Key（快照测试兼容）

struct CCAppThemeKey: EnvironmentKey {
    static let defaultValue: CCAppThemeProtocol = CCLightTheme()
}

extension EnvironmentValues {
    var ccAppTheme: CCAppThemeProtocol {
        get { self[CCAppThemeKey.self] }
        set { self[CCAppThemeKey.self] = newValue }
    }
}

// MARK: - CCThemeManager（v3.0 适配）

/// v3.0 设计系统改为 AppTheme 静态属性，不再通过协议注入
/// CCThemeManager 保留用于暗色模式切换控制
@MainActor
@Observable
final class CCThemeManager {
    /// 用户偏好：nil=跟随系统, false=浅色, true=深色
    var isDarkModeOverride: Bool? = nil

    /// 返回适合 preferredColorScheme 的值
    var colorScheme: ColorScheme? {
        guard let override = isDarkModeOverride else { return nil }
        return override ? .dark : .light
    }

    var isDarkMode: Bool {
        get { isDarkModeOverride ?? false }
        set { isDarkModeOverride = newValue }
    }

    /// 重置为跟随系统
    func resetToSystem() {
        isDarkModeOverride = nil
    }
}

// MARK: - 字体系统（Ardot 规范）

enum AppFont {
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)     // Ardot H1
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)         // Ardot H1
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)     // Ardot H2
    static let title3 = Font.system(size: 18, weight: .medium, design: .default)       // Ardot H3
    static let body = Font.system(size: 16, weight: .regular, design: .default)        // Ardot Body-L
    static let bodyBold = Font.system(size: 16, weight: .semibold, design: .default)
    static let caption = Font.system(size: 14, weight: .regular, design: .default)     // Ardot Body-M
    static let footnote = Font.system(size: 12, weight: .regular, design: .default)    // Ardot Body-S
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)    // Ardot Caption
}

// MARK: - 间距系统 (Ardot XuanSpacing)

enum AppSpacing {
    static let xs: CGFloat = 4     // Ardot 4pt
    static let sm: CGFloat = 8     // Ardot 8pt
    static let md: CGFloat = 12    // Ardot 12pt
    static let lg: CGFloat = 16    // Ardot 16pt
    static let xl: CGFloat = 20    // Ardot 20pt
    static let xxl: CGFloat = 24   // Ardot 24pt
    static let xxxl: CGFloat = 32  // Ardot 32pt
}

// MARK: - 圆角系统 (Ardot XuanRadius)

enum AppRadius {
    static let xs: CGFloat = 8     // Ardot sm (8pt), 弃用旧 6pt
    static let sm: CGFloat = 8     // Ardot sm 8pt
    static let md: CGFloat = 12    // Ardot md 12pt
    static let lg: CGFloat = 16    // Ardot lg 16pt
    static let xl: CGFloat = 20    // Ardot xl 20pt
    static let full: CGFloat = 9999
}

// MARK: - 阴影系统 (Ardot 中性棕)

enum AppShadow {
    /// 卡片阴影 — Ardot card: rgba(44,36,22,0.06) r12 y2
    static func card(color: Color = Color(hex: "2C2416")) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.06), radius: 12, x: 0, y: 2)
    }

    /// 浮层阴影 — Ardot float: rgba(44,36,22,0.10) r24 y4
    static func elevated(color: Color = Color(hex: "2C2416")) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.10), radius: 24, x: 0, y: 4)
    }

    /// 按压阴影 — Ardot press: rgba(44,36,22,0.08) r4 y1
    static func button(color: Color = Color(hex: "2C2416")) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.08), radius: 4, x: 0, y: 1)
    }
}
