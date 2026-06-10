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
        case .login:   CCLoginView()
        case .home:    CCHomeView()
        case .treeHole: CCTreeHoleView()
        case .voiceCheckin: CCVoiceCheckinView()
        case .voiceDiary: CCVoiceCheckinView()
        case .voiceEmotionDiary: CCVoiceCheckinView()
        case .journal: CCJournalView()
        case .trends: CCTrendsView()
        case .meditation: CCMeditationView()
        case .courses: CCCoursesView()
        case .vipCenter: CCMemberCenterView()
        case .transactionHistory: CCTransactionHistoryView()
        case .profile: CCProfileView()
        case .privacy: CCPrivacyView()
        case .dataManagement: CCDataManagementView()
        case .faq: CCFAQView()
        case .deleteAccount: CCDeleteAccountView()
        case .aiListener: CCAIListenerCard()
        case .resonanceWall: CCResonanceView()
        case .resonanceDetail(let p): CCResonanceDetailView(item: p)
        case .encourageChain: CCEncourageChainView()
        case .encourageChainDetail(let chainId): CCEncourageChainView(specificChainId: chainId)
        case .myEncourageChains: CCMyEncourageChainsView()
        case .emotionDecoder: CCEmotionDecoderView()
        case .postDetail(let p): CCTreeHolePostDetailView(post: p)
        case .courseDetail(let c): CCCourseDetailView(course: c)
        case .journalDetail(let e): CCJournalDetailView(entry: e)
        case .feedback: CCFeedbackView()
        case .userAgreement: CCUserAgreementView()
        case .privacyPolicy: CCPrivacyPolicyView()
        case .settings: CCSettingsView()
        case .meditationPlayer(let session): CCMeditationPlayerView(session: session)
        case .web(let url): CCWebView(url: url)
        }
    }

}
