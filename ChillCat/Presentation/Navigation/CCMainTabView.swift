import SwiftUI

enum CCMainTab: Int, CaseIterable {
    case home, treeHole, vip, profile
    var title: String {
        switch self {
        case .home: return "首页"; case .treeHole: return "树洞"
        case .vip: return "会员"; case .profile: return "我的"
        }
    }
    var iconName: String {
        switch self {
        case .home: return "house.fill"; case .treeHole: return "bubble.left.and.bubble.right.fill"
        case .vip: return "crown.fill"; case .profile: return "person.fill"
        }
    }
}

struct CCMainTabView: View {
    @State private var selectedTab: CCMainTab = .home
    @Environment(CCAppCoordinator.self) private var coordinator

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                coordinator.buildView(for: .home)
            }
            .tabItem { Label(CCMainTab.home.title, systemImage: CCMainTab.home.iconName) }
            .tag(CCMainTab.home)
                .accessibilityIdentifier("tab_home")

            NavigationStack {
                coordinator.buildView(for: .treeHole)
            }
            .tabItem { Label(CCMainTab.treeHole.title, systemImage: CCMainTab.treeHole.iconName) }
            .tag(CCMainTab.treeHole)
                .accessibilityIdentifier("tab_treehole")

            NavigationStack {
                coordinator.buildView(for: .vipCenter)
            }
            .tabItem { Label(CCMainTab.vip.title, systemImage: CCMainTab.vip.iconName) }
            .tag(CCMainTab.vip)
                .accessibilityIdentifier("tab_vip")

            NavigationStack {
                coordinator.buildView(for: .profile)
            }
            .tabItem { Label(CCMainTab.profile.title, systemImage: CCMainTab.profile.iconName) }
            .tag(CCMainTab.profile)
                .accessibilityIdentifier("tab_profile")
        }
    }
}
