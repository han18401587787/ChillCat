//
//  CCAppTheme.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

protocol CCAppThemeProtocol {
    // 主色调 - 蓝灰系
    var primary: Color { get }
    var primaryLight: Color { get }
    var primaryMuted: Color { get }
    // 暖调强调
    var warm: Color { get }
    var warmLight: Color { get }
    // 柔和紫
    var softPurple: Color { get }
    var softPurpleLight: Color { get }
    // 柔和绿
    var softGreen: Color { get }
    var softGreenLight: Color { get }
    // 柔和粉
    var softPink: Color { get }
    // 背景
    var background: Color { get }
    var surface: Color { get }
    var cardBackground: Color { get }
    // 文字
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textMuted: Color { get }
    // 状态色
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

// 绪安 - 亮色主题 (Figma 设计稿色板)
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

// 绪安 - 暗色主题
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

private extension Color {
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

struct CCAppThemeKey: EnvironmentKey {
    static let defaultValue: CCAppThemeProtocol = CCLightTheme()
}

extension EnvironmentValues {
    var ccAppTheme: CCAppThemeProtocol {
        get { self[CCAppThemeKey.self] }
        set { self[CCAppThemeKey.self] = newValue }
    }
}

@MainActor
@Observable
final class CCThemeManager {
    var currentTheme: CCAppThemeProtocol = CCLightTheme()

    var isDarkMode: Bool {
        get { currentTheme is CCDarkTheme }
        set { currentTheme = newValue ? CCDarkTheme() : CCLightTheme() }
    }
}
