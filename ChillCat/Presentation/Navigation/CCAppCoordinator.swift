import SwiftUI
import Observation

@MainActor
@Observable
final class CCAppCoordinator {
    var path = NavigationPath()
    var presentedSheet: CCAppRoute?
    var hasSeenWelcome = false
    var isLoggedIn: Bool

    init() { isLoggedIn = false }

    func navigate(to route: CCAppRoute) { path.append(route) }
    func presentSheet(_ route: CCAppRoute) { presentedSheet = route }
    func dismiss() { presentedSheet = nil }
    func popToRoot() { path.removeLast(path.count) }
    func pop() { guard !path.isEmpty else { return }; path.removeLast() }

    @ViewBuilder
    func buildView(for route: CCAppRoute) -> some View {
        switch route {
        case .welcome: CCWelcomeView()
        case .login:   CCLoginView()
        case .home:    CCHomeView()
        case .treeHole: CCTreeHoleView()
        case .voiceCheckin: CCVoiceCheckinView()
        case .journal: CCJournalView()
        case .trends: CCTrendsView()
        case .meditation: CCMeditationView()
        case .courses: CCCoursesView()
        case .vipCenter: CCMemberCenterView()
        case .profile: CCProfileView()
        case .privacy: CCPrivacyView()
        case .dataManagement: CCDataManagementView()
        case .faq: CCFAQView()
        case .deleteAccount: CCDeleteAccountView()
        case .settings: CCSettingsView()
        case .web(let url): CCWebView(url: url)
        }
    }
}
