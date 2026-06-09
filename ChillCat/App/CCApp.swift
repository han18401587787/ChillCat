import SwiftUI

struct CCApp: View {
    @State private var coordinator = CCAppCoordinator()
    @State private var themeManager = CCThemeManager()

    var body: some View {
        Group {
            if !coordinator.hasSeenWelcome {
                CCWelcomeView()
            } else if coordinator.isLoggedIn {
                CCMainTabView()
            } else {
                CCLoginView()
            }
        }
        .environment(\.ccAppTheme, themeManager.currentTheme)
        .environment(coordinator)
        .environment(themeManager)
    }
}
