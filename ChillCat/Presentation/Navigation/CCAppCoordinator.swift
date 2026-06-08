//
//  CCAppCoordinator.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI
import Observation

@MainActor
@Observable
final class CCAppCoordinator {
    var path = NavigationPath()
    var presentedSheet: CCAppRoute?
    var presentedFullScreen: CCAppRoute?
    var isLoggedIn: Bool

    private let diContainer: CCDIContainerProtocol

    init(diContainer: CCDIContainerProtocol) {
        self.diContainer = diContainer
        let tokenProvider: CCTokenProviderProtocol = diContainer.resolve()
        isLoggedIn = tokenProvider.accessToken != nil
    }

    // MARK: - Navigation Actions

    func navigate(to route: CCAppRoute) {
        path.append(route)
    }

    func presentSheet(_ route: CCAppRoute) {
        presentedSheet = route
    }

    func presentFullScreen(_ route: CCAppRoute) {
        presentedFullScreen = route
    }

    func dismiss() {
        if presentedSheet != nil {
            presentedSheet = nil
        } else if presentedFullScreen != nil {
            presentedFullScreen = nil
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // MARK: - View Builder

    @ViewBuilder
    func buildView(for route: CCAppRoute) -> some View {
        switch route {
        case .login:
            CCLoginView()
        case .home:
            CCHomeView()
        case .profile:
            CCProfileView()
        case .search:
            CCSearchView()
        case .messages:
            CCMessageListView()
        case .vipCenter:
            CCMemberCenterView()
        case .vipPurchase:
            CCMemberPurchaseView()
        case .settings:
            CCSettingsView()
        case .detail(let id):
            CCDetailView(itemId: id)
        case .web(let url):
            CCWebView(url: url)
        }
    }
}
