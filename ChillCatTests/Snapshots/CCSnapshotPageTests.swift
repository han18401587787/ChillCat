import XCTest
import SwiftUI
@testable import ChillCat

/// 核心页面快照测试
/// 首次运行 → 创建基线截图到 Snapshots/References/
/// 后续运行 → 像素比对，差异 > 0.5% 报错
final class CCSnapshotPageTests: XCTestCase {

    // MARK: Welcome

    func test_snapshot_welcomePage() {
        let view = CCWelcomeView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "welcome_page")
    }

    func test_snapshot_loginPage() {
        let view = CCLoginView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "login_page")
    }

    // MARK: Home

    func test_snapshot_homePage() {
        let view = CCHomeView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "home_page")
    }

    // MARK: TreeHole

    func test_snapshot_treeholePage() {
        let view = CCTreeHoleView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "treehole_page")
    }

    // MARK: Settings

    func test_snapshot_settingsPage() {
        let view = CCSettingsView()
            .environment(CCAppCoordinator())
            .environment(CCThemeManager())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "settings_page")
    }

    // MARK: Meditation

    func test_snapshot_meditationPage() {
        let view = CCMeditationView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "meditation_page")
    }

    // MARK: Courses

    func test_snapshot_coursesPage() {
        let view = CCCoursesView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "courses_page")
    }

    // MARK: Journal

    func test_snapshot_journalPage() {
        let view = CCJournalView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "journal_page")
    }

    // MARK: Trends

    func test_snapshot_trendsPage() {
        let view = CCTrendsView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
        CCSnapshotTesting.assertSnapshot(of: view, named: "trends_page")
    }
}
