//
//  CCAppTheme.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

protocol CCAppThemeProtocol {
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var background: Color { get }
    var surface: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var error: Color { get }
    var success: Color { get }
    var warning: Color { get }

    var spacingXS: CGFloat { get }
    var spacingSM: CGFloat { get }
    var spacingMD: CGFloat { get }
    var spacingLG: CGFloat { get }
    var spacingXL: CGFloat { get }

    var radiusSM: CGFloat { get }
    var radiusMD: CGFloat { get }
    var radiusLG: CGFloat { get }
}

struct CCLightTheme: CCAppThemeProtocol {
    let primary = Color.blue
    let secondary = Color.orange
    let accent = Color.purple
    let background = Color(.systemBackground)
    let surface = Color(.secondarySystemBackground)
    let textPrimary = Color(.label)
    let textSecondary = Color(.secondaryLabel)
    let error = Color.red
    let success = Color.green
    let warning = Color.orange

    let spacingXS: CGFloat = 4
    let spacingSM: CGFloat = 8
    let spacingMD: CGFloat = 16
    let spacingLG: CGFloat = 24
    let spacingXL: CGFloat = 32

    let radiusSM: CGFloat = 4
    let radiusMD: CGFloat = 8
    let radiusLG: CGFloat = 12
}

struct CCDarkTheme: CCAppThemeProtocol {
    let primary = Color.blue
    let secondary = Color.orange
    let accent = Color.purple
    let background = Color(.systemBackground)
    let surface = Color(.secondarySystemBackground)
    let textPrimary = Color(.label)
    let textSecondary = Color(.secondaryLabel)
    let error = Color.red
    let success = Color.green
    let warning = Color.orange

    let spacingXS: CGFloat = 4
    let spacingSM: CGFloat = 8
    let spacingMD: CGFloat = 16
    let spacingLG: CGFloat = 24
    let spacingXL: CGFloat = 32

    let radiusSM: CGFloat = 4
    let radiusMD: CGFloat = 8
    let radiusLG: CGFloat = 12
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
