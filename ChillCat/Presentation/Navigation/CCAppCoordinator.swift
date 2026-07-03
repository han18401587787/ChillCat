import SwiftUI
import Observation

@MainActor
@Observable
final class CCAppCoordinator {
    var path = NavigationPath()
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
        DispatchQueue.main.async { [self] in
            path.append(route)
        }
    }
    func presentSheet(_ route: CCAppRoute) {
        DispatchQueue.main.async { [self] in
            presentedSheet = route
        }
    }
    func dismiss() {
        DispatchQueue.main.async { [self] in
            presentedSheet = nil
        }
    }
    func popToRoot() {
        DispatchQueue.main.async { [self] in
            path.removeLast(path.count)
        }
    }
    func pop() {
        DispatchQueue.main.async { [self] in
            guard !path.isEmpty else { return }
            path.removeLast()
        }
    }

    /// Tab 切换时刷新当前 Tab 数据
    func refreshCurrentTab() {
        // 子 ViewModel 自行处理刷新逻辑
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
