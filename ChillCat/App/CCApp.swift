import SwiftUI
import KeychainAccess

struct CCApp: View {
    @State private var coordinator = CCAppCoordinator()
    @State private var themeManager = CCThemeManager()
    @State private var isInitializing = true
    @State private var initError: String?

    /// XCUITest 可通过 launchArguments 跳过 Welcome: `-UITEST_SKIP_WELCOME`
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITEST_SKIP_WELCOME")
    }

    var body: some View {
        Group {
            if isInitializing && !isUITesting {
                splashView
            } else if isUITesting || coordinator.hasSeenWelcome {
                if coordinator.isLoggedIn {
                    CCMainTabView()
                } else {
                    CCLoginView()
                }
            } else {
                CCWelcomeView()
            }
        }
        .environment(coordinator)
        .environment(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
        .task {
            guard !isUITesting else { return }
            await initializeApp()
        }
    }

    // MARK: - Splash
    private var splashView: some View {
        ZStack {
            Color.xuanApricotBg.ignoresSafeArea()
            VStack(spacing: XuanSpacing.lg) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.xuanMint)

                if let error = initError {
                    VStack(spacing: XuanSpacing.sm) {
                        Text("连接失败")
                            .font(XuanFont.h3)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text(error)
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                        Button("重试") {
                            initError = nil
                            Task { await initializeApp() }
                        }
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanApricot)
                        .padding(.top, XuanSpacing.sm)
                    }
                } else {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("正在连接...")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
    }

    // MARK: - Init
    private func initializeApp() async {
        isInitializing = true
        initError = nil

        let keychain = Keychain(service: "app.xuanpeace.token")

        // 如果已有有效 token，直接进入
        if let existingToken = keychain["access_token"], !existingToken.isEmpty {
            print("✅ [App] 已有 Token, 跳过匿名登录")
            coordinator.isLoggedIn = true
            isInitializing = false
            return
        }

        // 执行匿名登录获取 token
        print("🌐 [App] 开始匿名登录 → \(CCAppEnvironment.current.baseURL)")
        do {
            let resp = try await CCXuanAPI.anonymousLogin()
            keychain["access_token"] = resp.token
            print("✅ [App] 匿名登录成功 user=\(resp.username)")
            coordinator.isLoggedIn = true
        } catch {
            print("❌ [App] 匿名登录失败: \(error.localizedDescription)")
            // 如果是网络不可达，提示用户
            if (error as NSError).domain == NSURLErrorDomain {
                initError = "请检查网络连接后重试"
            } else {
                // 其他错误仍尝试进入（可能是服务器临时问题）
                initError = "服务器连接失败，请重试"
            }
        }
        isInitializing = false
    }
}
