//
//  UIDevice+CCExtension.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import UIKit

extension UIDevice {
    static var cc_isFullScreen: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return false }
        return window.safeAreaInsets.bottom > 0
    }

    static var cc_safeAreaTop: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.top
    }

    static var cc_safeAreaBottom: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.bottom
    }
}
