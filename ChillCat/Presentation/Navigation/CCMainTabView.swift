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

    /// 自定义图标名（对应 Assets.xcassets 中的 imageset）
    var iconName: String {
        switch self {
        case .home:          return "home_home"
        case .treeHole:      return "treehole_write"
        case .resonanceWall: return "resonance_like"
        case .healing:       return "healing_meditate"
        case .profile:       return "profile_user"
        }
    }
}

struct CCMainTabView: View {
    @State private var selectedTab: CCMainTab = .home
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                coordinator.buildView(for: .home)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label { Text(CCMainTab.home.title) } icon: { Image(CCMainTab.home.iconName) } }
            .tag(CCMainTab.home)

            NavigationStack(path: $coordinator.treeHolePath) {
                coordinator.buildView(for: .treeHole)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label { Text(CCMainTab.treeHole.title) } icon: { Image(CCMainTab.treeHole.iconName) } }
            .tag(CCMainTab.treeHole)

            NavigationStack(path: $coordinator.resonancePath) {
                coordinator.buildView(for: .resonanceWall)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label { Text(CCMainTab.resonanceWall.title) } icon: { Image(CCMainTab.resonanceWall.iconName) } }
            .tag(CCMainTab.resonanceWall)

            NavigationStack(path: $coordinator.healingPath) {
                coordinator.buildView(for: .healing)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label { Text(CCMainTab.healing.title) } icon: { Image(CCMainTab.healing.iconName) } }
            .tag(CCMainTab.healing)

            NavigationStack(path: $coordinator.profilePath) {
                coordinator.buildView(for: .profile)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label { Text(CCMainTab.profile.title) } icon: { Image(CCMainTab.profile.iconName) } }
            .tag(CCMainTab.profile)
        }
        .tint(Color.xuanApricot)
        .onChange(of: selectedTab) { _, newTab in
            coordinator.activeTab = newTab.rawValue
        }
        .onAppear {
            coordinator.activeTab = selectedTab.rawValue
            setupTabAccessibility()
        }
    }

    /// 通过 UIKit 桥接设置 TabBar 按钮的 accessibilityIdentifier
    /// 带重试机制：SwiftUI TabView 的 UITabBarItem 可能在首帧后才就绪，需要轮询等待
    private func setupTabAccessibility() {
        let maxRetries = 10
        let retryInterval: TimeInterval = 0.2
        var attempt = 0

        func trySetup() {
            guard let tabBarController = findTabBarController(),
                  let items = tabBarController.tabBar.items,
                  items.count >= CCMainTab.allCases.count else {
                attempt += 1
                if attempt < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval, execute: trySetup)
                } else {
                    print("⚠️ [UITest] TabBar accessibilityIdentifier 设置失败：超时（\(maxRetries)次重试）")
                }
                return
            }

            let tabs = CCMainTab.allCases
            for (index, tab) in tabs.enumerated() {
                items[index].accessibilityIdentifier = "tab_\(tab.title)"
            }
            print("✅ [UITest] TabBar accessibilityIdentifier 已设置（第\(attempt + 1)次尝试）")
        }

        DispatchQueue.main.async(execute: trySetup)
    }

    private func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return nil }

        if let tabVC = rootVC as? UITabBarController {
            return tabVC
        }
        for child in rootVC.children {
            if let tabVC = child as? UITabBarController {
                return tabVC
            }
        }
        return nil
    }
}
