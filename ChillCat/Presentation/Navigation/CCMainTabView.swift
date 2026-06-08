//
//  CCMainTabView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

enum CCMainTab: Int, CaseIterable {
    case home
    case search
    case vip
    case profile

    var title: String {
        switch self {
        case .home: return "首页"
        case .search: return "搜索"
        case .vip: return "会员"
        case .profile: return "我的"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .vip: return "crown.fill"
        case .profile: return "person.fill"
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
                    .navigationDestination(for: CCAppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .tabItem {
                Label(CCMainTab.home.title, systemImage: CCMainTab.home.iconName)
            }
            .tag(CCMainTab.home)

            NavigationStack {
                CCSearchView()
            }
            .tabItem {
                Label(CCMainTab.search.title, systemImage: CCMainTab.search.iconName)
            }
            .tag(CCMainTab.search)

            NavigationStack {
                CCMemberCenterView()
            }
            .tabItem {
                Label(CCMainTab.vip.title, systemImage: CCMainTab.vip.iconName)
            }
            .tag(CCMainTab.vip)

            NavigationStack {
                CCProfileView()
            }
            .tabItem {
                Label(CCMainTab.profile.title, systemImage: CCMainTab.profile.iconName)
            }
            .tag(CCMainTab.profile)
        }
    }
}
