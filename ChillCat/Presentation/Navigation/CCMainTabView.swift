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

    var iconName: String {
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
            // Tab 1: 首页
            NavigationStack {
                coordinator.buildView(for: .home)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem { Label(CCMainTab.home.title, systemImage: CCMainTab.home.iconName) }
            .tag(CCMainTab.home)
            .accessibilityIdentifier("tab_home")

            // Tab 2: 树洞
            NavigationStack {
                coordinator.buildView(for: .treeHole)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem { Label(CCMainTab.treeHole.title, systemImage: CCMainTab.treeHole.iconName) }
            .tag(CCMainTab.treeHole)
            .accessibilityIdentifier("tab_treehole")

            // Tab 3: 共鸣墙
            NavigationStack {
                coordinator.buildView(for: .resonanceWall)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem { Label(CCMainTab.resonanceWall.title, systemImage: CCMainTab.resonanceWall.iconName) }
            .tag(CCMainTab.resonanceWall)
            .accessibilityIdentifier("tab_resonance")

            // Tab 4: 治愈空间
            NavigationStack {
                coordinator.buildView(for: .healing)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem { Label(CCMainTab.healing.title, systemImage: CCMainTab.healing.iconName) }
            .tag(CCMainTab.healing)
            .accessibilityIdentifier("tab_healing")

            // Tab 5: 个人中心
            NavigationStack {
                coordinator.buildView(for: .profile)
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem { Label(CCMainTab.profile.title, systemImage: CCMainTab.profile.iconName) }
            .tag(CCMainTab.profile)
            .accessibilityIdentifier("tab_profile")
        }
        .tint(AppTheme.primary)
    }
}
