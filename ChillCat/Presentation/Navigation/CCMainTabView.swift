//
//  CCMainTabView.swift
//  绪安 v3.0 — 5 Tab 结构
//

import SwiftUI

enum CCMainTab: Int, CaseIterable {
    case home, treeHole, resonanceWall, healing, profile

    var title: String {
        switch self {
        case .home:          return "首页"
        case .treeHole:      return "树洞"
        case .resonanceWall: return "共鸣墙"
        case .healing:       return "治愈空间"
        case .profile:       return "个人中心"
        }
    }

    var sfSymbol: String {
        switch self {
        case .home:          return "house.fill"
        case .treeHole:      return "bubble.left.and.bubble.right.fill"
        case .resonanceWall: return "heart.fill"
        case .healing:       return "leaf.fill"
        case .profile:       return "person.fill"
        }
    }
}

struct CCMainTabView: View {
    @State private var selectedTab: CCMainTab = .home
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(CCMainTab.allCases, id: \.self) { tab in
                NavigationStack {
                    coordinator.buildView(for: routeFor(tab))
                        .navigationDestination(for: CCAppRoute.self) { route in
                            coordinator.buildView(for: route)
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.sfSymbol)
                }
                .tag(tab)
                // 关键修复: 通过 UITabBar 的 accessibility 属性暴露给 XCUITest
                .accessibilityIdentifier("tab_\(tab.rawValue)")
            }
        }
        .tint(Color.xuanApricot)
        // SwiftUI TabView 的 tabItem 不会直接暴露 label 文字作为 button identifier
        // XCUITest 需要通过 UITabBarButton 的 accessibilityLabel 来定位
        // 这里在 onAppear 时手动设置每个 tab button 的 accessibilityIdentifier
        .onAppear {
            setupTabAccessibility()
        }
    }

    /// 通过 UIKit 桥接设置 TabBar 按钮的 accessibilityIdentifier
    private func setupTabAccessibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let tabBarController = findTabBarController() else { return }
            let tabBar = tabBarController.tabBar

            let tabs = CCMainTab.allCases
            for (index, tab) in tabs.enumerated() {
                if index < tabBar.items?.count ?? 0 {
                    tabBar.items?[index].accessibilityIdentifier = "tab_\(tab.title)"
                }
            }
        }
    }

    private func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return nil }

        if let tabVC = rootVC as? UITabBarController {
            return tabVC
        }
        // 也可能嵌套在 NavigationController 中
        for child in rootVC.children {
            if let tabVC = child as? UITabBarController {
                return tabVC
            }
        }
        return nil
    }

    private func routeFor(_ tab: CCMainTab) -> CCAppRoute {
        switch tab {
        case .home:          return .home
        case .treeHole:      return .treeHole
        case .resonanceWall: return .resonanceWall
        case .healing:       return .healing
        case .profile:       return .profile
        }
    }
}
