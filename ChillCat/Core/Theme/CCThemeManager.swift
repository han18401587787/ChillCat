//
//  CCThemeManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026-06-27.
//

import SwiftUI
import Combine

/// 管理暗色模式切换
/// v3.0: AppTheme 改为静态属性后，CCThemeManager 仅负责 colorScheme 状态管理
@MainActor
@Observable
final class CCThemeManager {
    var colorScheme: ColorScheme? = nil

    var isDarkMode: Bool {
        colorScheme == .dark
    }

    func toggleTheme() {
        colorScheme = isDarkMode ? .light : .dark
    }

    func setLightMode() {
        colorScheme = .light
    }

    func setDarkMode() {
        colorScheme = .dark
    }

    func followSystem() {
        colorScheme = nil
    }
}
