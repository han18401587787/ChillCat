import SwiftUI
import KeychainAccess

#if DEBUG
import LookinServer
#endif

struct CCApp: View {
    @State private var coordinator = CCAppCoordinator()
    @State private var themeManager = CCThemeManager()
    @State private var isInitializing = true
    @State private var initError: String?
    @State private var retryAttempt = 0

    init() {
        #if DEBUG
        // 启动 Lookin Server 用于 UI 层级调试
        // macOS 端从 https://lookin.work/ 下载 Lookin App
        LookinServer.shared.start()
        #endif
    }

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
            if isUITesting {
                // UITest 模式：跳过初始化和欢迎页，直接进入主界面
                // - 有 -UITEST_AUTO_LOGIN → coordinator.isLoggedIn = true（模拟已登录）
                // - 无 -UITEST_AUTO_LOGIN → 未登录状态（测试登录页/离线场景）
                CCMainTabView()
                    .onAppear {
                        if isUITestAutoLogin {
                            coordinator.isLoggedIn = true
                            coordinator.isOffline = false
                        }
                        print("🧪 [UITest] 启动模式: isAutoLogin=\(isUITestAutoLogin)")
                    }
            } else if isInitializing {
                splashView
            } else if coordinator.isLoggedIn {
                CCMainTabView()
            } else if !coordinator.hasSeenWelcome {
                CCWelcomeView()
            } else {
                // 兜底：已看过欢迎页但未登录 → 也显示主界面（允许游客浏览）
                CCMainTabView()
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
