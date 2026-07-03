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
        @Bindable var coordinator = coordinator
        TabView(selection: $selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                coordinator.buildView(for: .home)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label(CCMainTab.home.title, systemImage: CCMainTab.home.sfSymbol) }
            .tag(CCMainTab.home)
            .accessibilityIdentifier("tab_\(CCMainTab.home.rawValue)")

            NavigationStack(path: $coordinator.treeHolePath) {
                coordinator.buildView(for: .treeHole)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label(CCMainTab.treeHole.title, systemImage: CCMainTab.treeHole.sfSymbol) }
            .tag(CCMainTab.treeHole)
            .accessibilityIdentifier("tab_\(CCMainTab.treeHole.rawValue)")

            NavigationStack(path: $coordinator.resonancePath) {
                coordinator.buildView(for: .resonanceWall)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label(CCMainTab.resonanceWall.title, systemImage: CCMainTab.resonanceWall.sfSymbol) }
            .tag(CCMainTab.resonanceWall)
            .accessibilityIdentifier("tab_\(CCMainTab.resonanceWall.rawValue)")

            NavigationStack(path: $coordinator.healingPath) {
                coordinator.buildView(for: .healing)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label(CCMainTab.healing.title, systemImage: CCMainTab.healing.sfSymbol) }
            .tag(CCMainTab.healing)
            .accessibilityIdentifier("tab_\(CCMainTab.healing.rawValue)")

            NavigationStack(path: $coordinator.profilePath) {
                coordinator.buildView(for: .profile)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                            .toolbar(.hidden, for: .tabBar)
                    }
            }
            .tabItem { Label(CCMainTab.profile.title, systemImage: CCMainTab.profile.sfSymbol) }
            .tag(CCMainTab.profile)
            .accessibilityIdentifier("tab_\(CCMainTab.profile.rawValue)")
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
        for child in rootVC.children {
            if let tabVC = child as? UITabBarController {
                return tabVC
            }
        }
        return nil
    }
}
