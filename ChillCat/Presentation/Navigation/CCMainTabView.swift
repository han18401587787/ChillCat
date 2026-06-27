import SwiftUI

/// Ardot v3 Tab 结构: 首页 / 树洞 / 共鸣墙 / 治愈空间 / 个人中心
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

    /// Ardot 自定义 SVG 图标 (Asset Catalog 名称)
    var activeIconName: String {
        switch self {
        case .home:          return "tab-home-active-homepage"
        case .treeHole:      return "tab-tree-active-treehollow"
        case .resonanceWall: return "tab-resonance-active-resonance"
        case .healing:       return "tab-healing-active-healing"
        case .profile:       return "tab-profile-active-profile"
        }
    }

    /// 非选中态图标（使用任意页面上下文的 inactive 版本）
    var inactiveIconName: String {
        switch self {
        case .home:          return "tab-home-inactive-treehollow"
        case .treeHole:      return "tab-tree-inactive-homepage"
        case .resonanceWall: return "tab-resonance-inactive-homepage"
        case .healing:       return "tab-healing-inactive-homepage"
        case .profile:       return "tab-profile-inactive-homepage"
        }
    }
}

struct CCMainTabView: View {
    @State private var selectedTab: CCMainTab = .home
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 首页
            NavigationStack {
                coordinator.buildView(for: .home)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                tabIcon(for: .home)
            }
            .tag(CCMainTab.home)
            .accessibilityIdentifier("tab_home")

            // Tab 2: 树洞
            NavigationStack {
                coordinator.buildView(for: .treeHole)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                tabIcon(for: .treeHole)
            }
            .tag(CCMainTab.treeHole)
            .accessibilityIdentifier("tab_treehole")

            // Tab 3: 共鸣墙
            NavigationStack {
                coordinator.buildView(for: .resonanceWall)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                tabIcon(for: .resonanceWall)
            }
            .tag(CCMainTab.resonanceWall)
            .accessibilityIdentifier("tab_resonance")

            // Tab 4: 治愈空间
            NavigationStack {
                coordinator.buildView(for: .healing)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                tabIcon(for: .healing)
            }
            .tag(CCMainTab.healing)
            .accessibilityIdentifier("tab_healing")

            // Tab 5: 个人中心
            NavigationStack {
                coordinator.buildView(for: .profile)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                tabIcon(for: .profile)
            }
            .tag(CCMainTab.profile)
            .accessibilityIdentifier("tab_profile")
        }
        .tint(AppTheme.primary)
    }

    @ViewBuilder
    private func tabIcon(for tab: CCMainTab) -> some View {
        let isSelected = selectedTab == tab
        Label {
            Text(tab.title)
        } icon: {
            Image(isSelected ? tab.activeIconName : tab.inactiveIconName)
                .renderingMode(.template)
        }
    }
}
