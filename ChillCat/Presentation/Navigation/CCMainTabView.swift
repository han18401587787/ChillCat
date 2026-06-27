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
                .accessibilityIdentifier("tab_\(tab.title)")
            }
        }
        .tint(Color.xuanApricot)
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
