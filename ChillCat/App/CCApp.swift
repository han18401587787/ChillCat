import SwiftUI
import KeychainAccess

struct CCApp: View {
    @State private var coordinator = CCAppCoordinator()
    @State private var themeManager = CCThemeManager()
    @State private var isInitializing = true
    @State private var initError: String?
    @State private var retryAttempt = 0

    /// XCUITest 可通过 launchArguments 跳过 Welcome: `-UITEST_SKIP_WELCOME`
    /// XCUITest 可通过 launchArguments 自动登录: `-UITEST_AUTO_LOGIN`
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITEST_SKIP_WELCOME")
    }
    private var isUITestAutoLogin: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITEST_AUTO_LOGIN")
    }

    var body: some View {
        Group {
            if isInitializing && !isUITesting {
                splashView
            } else if isUITestAutoLogin || coordinator.isLoggedIn {
                CCMainTabView()
            } else if isUITesting {
                // UITest 未设置自动登录 → 直接显示主界面（允许未登录状态测试）
                CCMainTabView()
            } else if coordinator.hasSeenWelcome {
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
                Image("emotion_calm")
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
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        HStack(spacing: XuanSpacing.md) {
                            Button("重试") {
                                retryAttempt = 0
                                initError = nil
                                Task { await initializeApp() }
                            }
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanApricot)
                            .padding(.top, XuanSpacing.sm)

                            Button("离线使用") {
                                print("🌐 [App] 用户选择离线模式")
                                coordinator.isLoggedIn = true
                                coordinator.isOffline = true
                                isInitializing = false
                            }
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanTextSecondary)
                            .padding(.top, XuanSpacing.sm)
                        }
                    }
                } else {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text(retryAttempt > 0 ? "正在重试 (\(retryAttempt)/3)..." : "正在连接...")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
    }

    // MARK: - Init（带指数退避重试 + 离线模式）
    private func initializeApp() async {
        isInitializing = true
        initError = nil

        let keychain = Keychain(service: "app.xuanpeace.token")

        // 如果已有有效 token，直接进入
        if let existingToken = keychain["access_token"], !existingToken.isEmpty {
            print("✅ [App] 已有 Token, 跳过匿名登录")
            coordinator.isLoggedIn = true
            coordinator.isOffline = false
            isInitializing = false
            return
        }

        // 执行匿名登录（带指数退避重试）
        let maxRetries = 3
        let baseDelay: UInt64 = 1_000_000_000 // 1 秒

        for attempt in 1...maxRetries {
            retryAttempt = attempt
            print("🌐 [App] 匿名登录尝试 \(attempt)/\(maxRetries) → \(CCAppEnvironment.current.baseURL)")

            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                keychain["access_token"] = resp.token
                print("✅ [App] 匿名登录成功 user=\(resp.username)")
                coordinator.isLoggedIn = true
                coordinator.isOffline = false
                isInitializing = false
                return
            } catch {
                print("❌ [App] 匿名登录失败 (attempt \(attempt)/\(maxRetries)): \(error.localizedDescription)")

                if attempt < maxRetries {
                    // 指数退避：1s → 2s → 4s
                    let delay = baseDelay * UInt64(pow(2.0, Double(attempt - 1)))
                    print("⏳ [App] 等待 \(Double(delay) / 1_000_000_000)s 后重试...")
                    try? await Task.sleep(nanoseconds: delay)
                } else {
                    // 所有重试均失败 — 允许离线模式进入
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain {
                        switch nsError.code {
                        case NSURLErrorNotConnectedToInternet,
                             NSURLErrorNetworkConnectionLost:
                            initError = "网络连接不可用，请检查网络后重试，或选择离线使用"
                        case NSURLErrorTimedOut:
                            initError = "连接超时，请检查网络后重试"
                        case NSURLErrorCannotConnectToHost,
                             NSURLErrorCannotFindHost,
                             NSURLErrorDNSLookupFailed:
                            initError = "无法连接到服务器，请稍后重试"
                        default:
                            initError = "请检查网络连接后重试"
                        }
                    } else {
                        initError = "服务器连接失败，请重试或选择离线使用"
                    }
                }
            }
        }

        isInitializing = false
    }
}
