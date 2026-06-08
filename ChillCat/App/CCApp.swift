//
//  CCApp.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

struct CCApp: View {
    @State private var coordinator: CCAppCoordinator
    @State private var themeManager = CCThemeManager()

    init() {
        let diContainer = CCAppDependencyContainer.shared.container
        _coordinator = State(initialValue: CCAppCoordinator(diContainer: diContainer))
    }

    var body: some View {
        Group {
            if coordinator.isLoggedIn {
                CCMainTabView()
                    .sheet(item: $coordinator.presentedSheet) { route in
                        NavigationStack {
                            coordinator.buildView(for: route)
                        }
                    }
                    .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
                        NavigationStack {
                            coordinator.buildView(for: route)
                        }
                    }
            } else {
                CCLoginView()
            }
        }
        .environment(\.ccAppTheme, themeManager.currentTheme)
        .environment(coordinator)
        .environment(themeManager)
    }
}
