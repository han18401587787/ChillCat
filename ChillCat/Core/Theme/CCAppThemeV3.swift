import SwiftUI

// MARK: - CCAppTheme v3.0
/// 绪安设计系统 - 基于v2 CCAppTheme 增量升级
/// 保留v2所有色值（作为兼容别名），新增v3语义化Token
/// 使用方式：AppTheme.primary / AppSpacing.md / AppRadius.lg
enum AppTheme {
    // MARK: - 主色调（与v2一致）
    
    static let primary = Color(hex: "5A7A8A")
    static let primaryLight = Color(hex: "7A9AAA")
    static let primaryDark = Color(hex: "4A6A7A")
    /// v2兼容别名：primaryMuted → v2 色值 #B8D4E3
    static let primaryMuted = Color(hex: "B8D4E3")
    
    // MARK: - 暖调（与v2一致）
    
    /// v2兼容别名：warm → v2 色值 #8B6F47
    static let warm = Color(hex: "8B6F47")
    /// v2兼容别名：warmLight → v2 色值 #C9A063
    static let warmLight = Color(hex: "C9A063")
    /// v2兼容别名：warmMuted → v2 色值 #EBE2D5
    static let warmMuted = Color(hex: "EBE2D5")
    
    // MARK: - 柔和色（与v2一致）
    
    /// v2兼容别名：softPurple → v2 色值 #D4C8E8
    static let softPurple = Color(hex: "D4C8E8")
    /// v2兼容别名：softPurpleLight → v2 色值 #E8D9F0
    static let softPurpleLight = Color(hex: "E8D9F0")
    /// v2兼容别名：softGreen → v2 色值 #66BB6A
    static let softGreen = Color(hex: "66BB6A")
    /// v2兼容别名：softGreenLight → v2 色值 #D5E8D4
    static let softGreenLight = Color(hex: "D5E8D4")
    /// v2兼容别名：softPink → v2 色值 #E8B8C8
    static let softPink = Color(hex: "E8B8C8")
    /// v2兼容别名：softPinkLight → v2 色值 #F2D5E0
    static let softPinkLight = Color(hex: "F2D5E0")
    
    // MARK: - 背景色（与v2一致，Ardot设计规范）
    
    static let background = Color(hex: "F9F6F2")
    static let backgroundSecondary = Color(hex: "F0EDE8")
    static let surface = Color.white
    static let surfaceSecondary = Color(hex: "F0EDE8")
    /// v2兼容别名：cardBackground → #FFFFFF
    static let cardBackground = Color.white
    
    // MARK: - 文字色（与v2一致，Ardot设计规范）
    
    static let textPrimary = Color(hex: "2D2D2D")
    static let textSecondary = Color(hex: "7A7A7A")
    static let textTertiary = Color(hex: "AAAAAA")
    static let textInverse = Color.white
    /// v2兼容别名：textMuted → 同 textTertiary #AAAAAA
    static let textMuted = Color(hex: "AAAAAA")
    
    // MARK: - 状态色（与v2一致）
    
    /// v2兼容别名：error → v2 色值 #E57373
    static let error = Color(hex: "E57373")
    /// v2兼容别名：success → v2 色值 #66BB6A
    static let success = Color(hex: "66BB6A")
    
    // MARK: - 边框/分隔线
    
    static let border = Color(hex: "E5E0D8")
    static let divider = Color(hex: "F0EDE8")
    
    // MARK: - v3.0 新增语义化颜色Token（10个）
    
    /// 危机红 - 用于紧急状态/高危提示（v3新增）
    static let crisisRed = error
    static let crisisRedLight = Color(hex: "FFCDD2")
    static let crisisRedDark = Color(hex: "C62828")
    
    /// 安全绿 - 用于稳定状态/安全标识（v3新增）
    static let safeGreen = success
    static let safeGreenLight = Color(hex: "C8E6C9")
    static let safeGreenDark = Color(hex: "388E3C")
    
    /// 暖光 - 用于温暖提示/鼓励（v3新增，与v2 warm不同色系）
    static let warmGlow = Color(hex: "FFD700")
    static let warmGlowLight = Color(hex: "FFF9C4")
    static let warmGlowDark = Color(hex: "F9A825")
    
    /// 柔和紫 - 用于冥想/放松场景（v3新增，Material Design色系）
    static let softPurpleV3 = Color(hex: "CE93D8")
    static let softPurpleV3Light = Color(hex: "F3E5F5")
    
    /// 宁静蓝 - 用于睡眠/平静场景（v3新增）
    static let calmBlue = Color(hex: "64B5F6")
    static let calmBlueLight = Color(hex: "E3F2FD")
    
    /// 活力橙 - 用于激励/提醒（v3新增）
    static let vibrantOrange = Color(hex: "FF8A65")
    static let vibrantOrangeLight = Color(hex: "FBE9E7")
    
    /// 希望青 - 用于成长/进步（v3新增）
    static let hopeCyan = Color(hex: "4DD0E1")
    static let hopeCyanLight = Color(hex: "E0F7FA")
    
    /// 深空灰 - 用于高级感卡片背景（v3新增）
    static let deepSpaceGray = Color(hex: "37474F")
    static let deepSpaceGrayLight = Color(hex: "ECEFF1")
    
    /// 玫瑰金 - 用于温柔强调（v3新增）
    static let roseGold = Color(hex: "F48FB1")
    static let roseGoldLight = Color(hex: "FCE4EC")
    
    /// 薄荷绿 - 用于清新/新生（v3新增）
    static let mintGreen = Color(hex: "80CBC4")
    static let mintGreenLight = Color(hex: "E0F2F1")
    
    // MARK: - 语义化颜色（v3新增）
    
    static let homeGradientStart = primary
    static let homeGradientEnd = Color(hex: "7EC8E3")
    static let alertBackground = crisisRedLight
    static let alertForeground = crisisRed
    static let checkinComplete = safeGreen
    static let checkinPending = textTertiary
    static let encouragementChain = warmGlow
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 字体系统
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

// MARK: - 间距系统（Ardot设计规范：6/10/16/24/32 + v3扩展）
enum AppSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    /// v3新增：超大间距
    static let xxl: CGFloat = 48
    /// v3新增：超超大间距
    static let xxxl: CGFloat = 64
}

// MARK: - 圆角系统（Ardot设计规范：8/12/16/24）
enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - 阴影系统
enum AppShadow {
    static func card() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    static func elevated() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }
    
    static func button() -> some View {
        Color.clear
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
