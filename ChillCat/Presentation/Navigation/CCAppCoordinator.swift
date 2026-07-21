import SwiftUI
import Observation
import Combine

@MainActor
@Observable
final class CCAppCoordinator {
    // 每个 Tab 独立的 NavigationPath
    var homePath = NavigationPath()
    var treeHolePath = NavigationPath()
    var resonancePath = NavigationPath()
    var healingPath = NavigationPath()
    var profilePath = NavigationPath()
    var activeTab: Int = 0

    var presentedSheet: CCAppRoute?
    var hasSeenWelcome = false
    var isLoggedIn: Bool
    var isOffline: Bool = false

    // MARK: - Shared ViewModels（跨 Tab 保持生命周期）
    let emotionViewModel = CCEmotionViewModel()
    let resonanceViewModel = CCResonanceViewModel()
    let treeHoleViewModel = CCTreeHoleViewModel()

    init() { isLoggedIn = false }

    func navigate(to route: CCAppRoute) {
        switch activeTab {
        case 0: homePath.append(route)
        case 1: treeHolePath.append(route)
        case 2: resonancePath.append(route)
        case 3: healingPath.append(route)
        case 4: profilePath.append(route)
        default: homePath.append(route)
        }
    }

    func presentSheet(_ route: CCAppRoute) {
        presentedSheet = route
    }

    func dismiss() {
        presentedSheet = nil
    }

    func popToRoot() {
        switch activeTab {
        case 0: homePath.removeLast(homePath.count)
        case 1: treeHolePath.removeLast(treeHolePath.count)
        case 2: resonancePath.removeLast(resonancePath.count)
        case 3: healingPath.removeLast(healingPath.count)
        case 4: profilePath.removeLast(profilePath.count)
        default: break
        }
    }

    func pop() {
        switch activeTab {
        case 0: guard !homePath.isEmpty else { return }; homePath.removeLast()
        case 1: guard !treeHolePath.isEmpty else { return }; treeHolePath.removeLast()
        case 2: guard !resonancePath.isEmpty else { return }; resonancePath.removeLast()
        case 3: guard !healingPath.isEmpty else { return }; healingPath.removeLast()
        case 4: guard !profilePath.isEmpty else { return }; profilePath.removeLast()
        default: break
        }
    }

    @ViewBuilder
    func buildView(for route: CCAppRoute) -> some View {
        switch route {
        case .login:   CCLoginView()
        case .home:    CCHomeView(viewModel: emotionViewModel)
        case .treeHole: CCTreeHoleView(viewModel: treeHoleViewModel)
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
        case .resonanceWall: CCResonanceView(viewModel: resonanceViewModel)
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
        case .professionalResources: CCProfessionalResourceView()
        case .safetyPlan: CCSafetyPlanView()
        case .crisisHotline: CCCrisisHotlineView()
        case .toolbox: CCToolboxView()
        case .breathingExercise: CCToolboxView()
        case .cbtRestructuring: CCCBTView()
        case .progressiveMuscleRelaxation: CCPMRView()
        case .bodyScan: CCBodyScanView()
        case .valuesExplorer: CCValuesExplorerView()
        case .gratitudeJournal: CCGratitudeJournalView()
        case .behavioralActivation: CCBehavioralActivationView()
        case .healing: CCMeditationView()
        case .growthArchive: CCGrowthArchiveView()
        case .growthReport: CCGrowthReportView()
        case .mutualAidGroups: CCMutualAidGroupView()
        case .mutualAidGroupDetail(let id): CCMutualAidGroupView()
        case .stablePlan: CCStablePlanView()
        case .rainSound: CCRainSoundView()
        case .emotionRecord: CCEmotionRecordView()
        case .checkinSuccess: CCCheckinResultView()
        case .emotionDecodeResult: CCEmotionDecodeResultView()
        }
    }

}
