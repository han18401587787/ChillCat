import SwiftUI

// MARK: - CCAppTheme 暖色调全面重构
/// 绪安设计系统 — 基于色彩心理学（Headspace/Calm 最佳实践）
/// 从"灰蓝冷色调"全面转向"暖色调温暖治愈"体系
/// 实现每日主题色切换 + 字体语义化Token + 圆角/阴影升级
///
/// 使用方式：AppTheme.primary / AppTheme.accent / AppSpacing.md / AppRadius.lg

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

// MARK: - 字体语义化 Token

enum FontToken {
    /// 主问候语/大标题 28pt Medium Rounded
    case greetingTitle
    /// 卡片标题/Section 20pt Medium Rounded
    case sectionTitle
    /// 正文/对话 16pt Regular, lineHeight 1.65
    case bodyComfortable
    /// 长文/情绪日记 15pt Regular, lineHeight 1.7
    case journalText
    /// 大数字 Semibold Rounded
    case numberWarm(CGFloat)
    /// 按钮文字 16pt Medium Rounded
    case buttonLabel
    /// 辅助说明 13pt Regular
    case caption

    var font: Font {
        switch self {
        case .greetingTitle:
            return .system(size: 28, weight: .medium, design: .rounded)
        case .sectionTitle:
            return .system(size: 20, weight: .medium, design: .rounded)
        case .bodyComfortable:
            return .system(size: 16, weight: .regular, design: .default)
        case .journalText:
            return .system(size: 15, weight: .regular, design: .default)
        case .numberWarm(let size):
            return .system(size: size, weight: .semibold, design: .rounded)
        case .buttonLabel:
            return .system(size: 16, weight: .medium, design: .rounded)
        case .caption:
            return .system(size: 13, weight: .regular, design: .default)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .greetingTitle:  return 0
        case .sectionTitle:   return 0
        case .bodyComfortable: return 16 * 0.65  // 1.65 lineHeight → spacing
        case .journalText:     return 15 * 0.70  // 1.7 lineHeight → spacing
        case .numberWarm:      return 0
        case .buttonLabel:     return 0
        case .caption:         return 0
        }
    }
}

// MARK: - AppTheme 颜色系统

enum AppTheme {
    // MARK: - v3 暖色系基础色

    static let warmOrange  = Color(hex: "E8895C")   // 暖杏橙（默认主色）
    static let warmBlue    = Color(hex: "7A9AAA")   // 勇气蓝（提亮）
    static let warmGreen   = Color(hex: "7CB887")   // 治愈绿
    static let warmGold    = Color(hex: "D4A85C")   // 温暖金
    static let warmOrange2 = Color(hex: "F5A623")   // 喜悦橙
    static let warmPurple  = Color(hex: "A085C6")   // 宁静紫
    static let warmPink    = Color(hex: "E8B4B0")   // 温柔粉

    // MARK: - 背景/表面（暖奶油系）

    static let background   = Color(hex: "FFF5F0")  // 暖奶油背景
    static let surface      = Color(hex: "FFF0E8")  // 暖桃白表面
    static let surfaceHover = Color(hex: "FFE8DC")  // 暖桃表面悬停

    // MARK: - 文字（暖棕系，禁止纯黑）

    static let textPrimary   = Color(hex: "3D2E28")  // 暖棕黑
    static let textSecondary = Color(hex: "9B8579")  // 暖灰褐
    static let textMuted     = Color(hex: "C4AFA3")  // 暖灰

    // MARK: - 功能色

    static let success = Color(hex: "7CB887")  // 暖鼠尾草绿
    static let warning = Color(hex: "D4A85C")  // 暖蜂蜜金
    static let error   = Color(hex: "E8846E")  // 暖珊瑚红
    static let info    = Color(hex: "7A9AAA")  // 暖蓝

    // MARK: - 强调色

    static let accentGreen = Color(hex: "7CB887")
    static let accentPink  = Color(hex: "E8B4B0")
    static let accentGold  = Color(hex: "D4A85C")

    // MARK: - 动态主色（每日主题）

    /// 根据当天星期自动切换主色
    static var accent: Color { DayTheme.current.primary }

    // MARK: - 语义化颜色

    static let homeGradientStart = warmOrange
    static let homeGradientEnd   = warmOrange2
    static let alertBackground   = Color(hex: "FFE8DC")
    static let alertForeground   = error
    static let checkinComplete   = success
    static let checkinPending    = textMuted
    static let encouragementChain = warmGold

    // MARK: - v2 兼容别名（全部保留，确保旧引用不报错）

    /// v2: primary → #5A7A8A
    static let primary = warmOrange
    /// v2: primaryLight → #7A9AAA
    static let primaryLight = warmBlue
    /// v2: primaryDark → #4A6A7A
    static let primaryDark = Color(hex: "6A8A9A")
    /// v2: primaryMuted → #B8D4E3
    static let primaryMuted = warmOrange.opacity(0.6)

    /// v2: warm → #8B6F47
    static let warm = warmGold
    /// v2: warmLight → #C9A063
    static let warmLight = Color(hex: "E8C98C")
    /// v2: warmMuted → #EBE2D5
    static let warmMuted = Color(hex: "F5EBDC")

    /// v2: softPurple → #D4C8E8
    static let softPurple = warmPurple.opacity(0.5)
    /// v2: softPurpleLight → #E8D9F0
    static let softPurpleLight = warmPurple.opacity(0.25)
    /// v2: softGreen → #66BB6A
    static let softGreen = warmGreen
    /// v2: softGreenLight → #D5E8D4
    static let softGreenLight = warmGreen.opacity(0.25)
    /// v2: softPink → #E8B8C8
    static let softPink = warmPink
    /// v2: softPinkLight → #F2D5E0
    static let softPinkLight = warmPink.opacity(0.25)

    /// v2: background → #F9F6F2
    static let backgroundSecondary = surface
    /// v2: surface → white
    static let surfaceSecondary = surface
    /// v2: cardBackground → #FFFFFF
    static let cardBackground = Color.white

    /// v2: textSecondary → #7A7A7A
    /// v2: textTertiary → #AAAAAA
    static let textTertiary = textMuted
    /// v2: textInverse → white
    static let textInverse = Color.white

    /// v2: border → #E5E0D8
    static let border = Color(hex: "E8DDD0")
    /// v2: divider → #F0EDE8
    static let divider = Color(hex: "F5EDE4")

    // MARK: - v3 语义化颜色 Token（v3新增，暖化版）

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

    /// 柔和紫 - 用于冥想/放松场景

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

    /// 薄荷绿 - 用于清新/新生
    static let mintGreen = warmGreen.opacity(0.7)
    static let mintGreenLight = warmGreen.opacity(0.15)
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

// MARK: - 亮色主题（快照测试兼容）

struct CCLightTheme: CCAppThemeProtocol {
    let primary = Color(hex: "5A7A8A")
    let primaryLight = Color(hex: "7A9AAA")
    let primaryMuted = Color(hex: "B8D4E3")
    let warm = Color(hex: "8B6F47")
    let warmLight = Color(hex: "C9A063")
    let softPurple = Color(hex: "D4C8E8")
    let softPurpleLight = Color(hex: "E8D9F0")
    let softGreen = Color(hex: "66BB6A")
    let softGreenLight = Color(hex: "D5E8D4")
    let softPink = Color(hex: "E8B8C8")
    let softPinkLight = Color(hex: "F2D5E0")
    let warmMuted = Color(hex: "EBE2D5")
    let background = Color(hex: "F9F6F2")
    let surface = Color(hex: "F0EDE8")
    let cardBackground = Color.white
    let textPrimary = Color(hex: "2D2D2D")
    let textSecondary = Color(hex: "7A7A7A")
    let textMuted = Color(hex: "AAAAAA")
    let error = Color(hex: "E57373")
    let success = Color(hex: "66BB6A")
    let spacingXS: CGFloat = 6
    let spacingSM: CGFloat = 10
    let spacingMD: CGFloat = 16
    let spacingLG: CGFloat = 24
    let spacingXL: CGFloat = 32
    let radiusSM: CGFloat = 8
    let radiusMD: CGFloat = 12
    let radiusLG: CGFloat = 16
    let radiusXL: CGFloat = 24
}

// MARK: - 暗色主题（快照测试兼容）

struct CCDarkTheme: CCAppThemeProtocol {
    let primary = Color(hex: "7A9AAA")
    let primaryLight = Color(hex: "5A7A8A")
    let primaryMuted = Color(hex: "3D5560")
    let warm = Color(hex: "C9A063")
    let warmLight = Color(hex: "8B6F47")
    let softPurple = Color(hex: "9B8DB8")
    let softPurpleLight = Color(hex: "6B5D88")
    let softGreen = Color(hex: "66BB6A")
    let softGreenLight = Color(hex: "3D7040")
    let softPink = Color(hex: "C890A0")
    let softPinkLight = Color(hex: "A87888")
    let warmMuted = Color(hex: "3D3528")
    let background = Color(hex: "1A1D1F")
    let surface = Color(hex: "242729")
    let cardBackground = Color(hex: "2D3033")
    let textPrimary = Color(hex: "E8E8E8")
    let textSecondary = Color(hex: "999999")
    let textMuted = Color(hex: "666666")
    let error = Color(hex: "E57373")
    let success = Color(hex: "66BB6A")
    let spacingXS: CGFloat = 6
    let spacingSM: CGFloat = 10
    let spacingMD: CGFloat = 16
    let spacingLG: CGFloat = 24
    let spacingXL: CGFloat = 32
    let radiusSM: CGFloat = 8
    let radiusMD: CGFloat = 12
    let radiusLG: CGFloat = 16
    let radiusXL: CGFloat = 24
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

// MARK: - 字体系统（保留 v2 兼容）

enum AppFont {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let caption = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - 间距系统（保留 v2 兼容）

enum AppSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - 圆角系统（v3 升级）

enum AppRadius {
    static let xs: CGFloat = 6    // v3: 4→6
    static let sm: CGFloat = 12   // v3: 8→12
    static let md: CGFloat = 16   // v3: 12→16
    static let lg: CGFloat = 24   // v3: 16→24
    static let xl: CGFloat = 32   // v3: 24→32
    static let full: CGFloat = 9999
}

// MARK: - 阴影系统（v3 升级：品牌暖色叠加）

enum AppShadow {
    /// 卡片阴影 — 使用品牌暖色叠加
    static func card(color: Color = AppTheme.warmOrange) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    static func elevated(color: Color = AppTheme.warmOrange) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.10), radius: 16, x: 0, y: 6)
    }

    static func button(color: Color = AppTheme.warmOrange) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}
