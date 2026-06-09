import SwiftUI

struct CCApp: View {
    @State private var coordinator = CCAppCoordinator()
    @State private var themeManager = CCThemeManager()

    /// XCUITest 可通过 launchArguments 跳过 Welcome: `-UITEST_SKIP_WELCOME`
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITEST_SKIP_WELCOME")
    }

    var body: some View {
        Group {
            if isUITesting || coordinator.hasSeenWelcome {
                if coordinator.isLoggedIn {
                    CCMainTabView()
                } else {
                    CCLoginView()
                }
            } else {
                CCWelcomeView()
            }
        }
        .environment(\.ccAppTheme, themeManager.currentTheme)
        .environment(coordinator)
        .environment(themeManager)
    }
}
