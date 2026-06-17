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
        // v3.0: 设计系统改为 AppTheme 静态属性，不再通过 Environment 注入
        // CCThemeManager 保留用于暗色模式切换（后续版本实现）
        .environment(coordinator)
        .environment(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
    }
}
