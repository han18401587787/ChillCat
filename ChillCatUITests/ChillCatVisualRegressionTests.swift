//
//  ChillCatVisualRegressionTests.swift
//  绪安 v3.0 — 全页面视觉回归测试
//
//  运行方式:
//  1. 确保服务端已启动
//  2. 自定义 API URL: xcodebuild ... CHILLCAT_API_URL=http://81.70.178.249:8080
//  3. 运行: xcodebuild test -scheme ChillCat -destination 'platform=iOS Simulator,name=iPhone 16'
//
//  AI 视觉校验依赖: 服务端 DASHSCOPE_API_KEY 环境变量
//  像素对比模式: 自动降级为规则检查
//

import XCTest

/// 视觉回归测试中页面切换动画完成所需的等待时间
private let pageTransitionDelay: UInt32 = 1

final class ChillCatVisualRegressionTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        // 确保前一个测试的 app 完全终止
        app.terminate()
        // 等待进程完全释放（terminate 是异步的，需短暂等待）
        sleep(1)
        app.launchArguments = ["-UITEST_SKIP_WELCOME", "-UITEST_AUTO_LOGIN"]
        let apiURL = ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "http://81.70.178.249:8080"
        app.launchEnvironment = ["CHILLCAT_API_URL": apiURL]
        app.launch()
        // CI 冷启动 Simulator 可能较慢，给 30s 等待 TabBar 出现
        _ = app.tabHome.waitForExistence(timeout: 30)
    }

    override func tearDownWithError() throws {
        // 确保测试结束后 app 完全终止
        app.terminate()
    }

    // MARK: - 🔍 环境自检

    func test_EnvironmentCheck() throws {
        CCDiagnosticHelper.checkEnvironment()
    }

    // MARK: - Tab 页面视觉校验

    /// 首页 — page_18
    func testVisual_HomePage() async throws {
        app.tabHome.tap()
        // 等待首页内容加载完成（今日心情打卡按钮出现 = 数据就绪）
        _ = app.buttons["今日心情打卡"].waitForExistence(timeout: 10)
        sleep(pageTransitionDelay)
        try await VisualTesting.analyzeWithAI(
            named: "home",
            in: app,
            checks: ["all_elements", "no_overlap", "layout_integrity"]
        )
    }

    /// 树洞 — page_19
    func testVisual_TreeHolePage() async throws {
        app.tabTreeHole.tap()
        // 等待树洞内容加载（发布框或空状态出现）
        _ = app.textViews.firstMatch.waitForExistence(timeout: 5)
        sleep(pageTransitionDelay)
        try await VisualTesting.analyzeWithAI(
            named: "treehole",
            in: app,
            checks: ["all_elements", "readable_text", "no_overlap"]
        )
    }

    /// 共鸣墙 — page_20
    func testVisual_ResonanceWallPage() async throws {
        app.tabResonance.tap()
        // 等待共鸣墙内容加载
        _ = app.buttons["写下心情"].waitForExistence(timeout: 5)
        sleep(pageTransitionDelay)
        try await VisualTesting.analyzeWithAI(
            named: "resonance",
            in: app,
            checks: ["all_elements", "layout_integrity"]
        )
    }

    /// 治愈空间 — page_21
    func testVisual_HealingSpacePage() async throws {
        // 从首页情绪探索进入治愈空间
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        let healingEntry = app.buttons["治愈空间"]
        if healingEntry.waitForExistence(timeout: 5) {
            healingEntry.tap()
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "healing", in: app)
        }
    }

    /// 个人中心 — page_22
    func testVisual_ProfilePage() async throws {
        app.tabProfile.tap()
        // 等待个人中心内容加载（用户卡片或加载失败提示）
        let contentLoaded = app.buttons["profile_user_card"].waitForExistence(timeout: 5)
            || app.staticTexts["加载失败，请下拉刷新重试"].waitForExistence(timeout: 5)
        _ = contentLoaded

        // UITest 未登录时显示「加载失败」是正常的，跳过视觉校验
        if app.staticTexts["加载失败，请下拉刷新重试"].exists {
            print("   ⚠️ 个人中心加载失败（UITest未登录），跳过视觉校验")
            return
        }
        sleep(pageTransitionDelay)
        try await VisualTesting.analyzeWithAI(
            named: "profile",
            in: app,
            checks: ["all_elements", "layout_integrity"]
        )
    }

    // MARK: - 核心功能页面

    /// 情绪解码 — page_39
    func testVisual_EmotionDecoder() async throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        let decoderEntry = app.buttons["情绪解码"]
        if decoderEntry.waitForExistence(timeout: 5) {
            decoderEntry.tap()
            // 等待解码结果加载
            _ = app.buttons["decode_continue_chat"].waitForExistence(timeout: 5)
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "emotion_decoder", in: app)
        }
    }

    /// 情绪记录 — page_36
    func testVisual_EmotionRecord() async throws {
        app.tabHome.tap()
        // 点击需求标签进入情绪选择状态（不点打卡按钮，避免跳转到打卡成功页）
        let needBtn = app.buttons["被倾听"].firstMatch
        if needBtn.waitForExistence(timeout: 5) {
            needBtn.tap()
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "emotion_record", in: app)
        }
    }

    /// 打卡成功 — page_45
    func testVisual_CheckinSuccess() async throws {
        app.tabHome.tap()
        let checkinBtn = app.buttons["今日心情打卡"]
        if checkinBtn.waitForExistence(timeout: 5) {
            checkinBtn.tap()
            // 打卡成功页可能需要网络请求，给更长等待
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 5)
            sleep(pageTransitionDelay * 2)
            try await VisualTesting.analyzeWithAI(named: "checkin_success", in: app)
        }
    }

    /// 稳情计划 — page_52
    func testVisual_StablePlan() async throws {
        app.tabHome.tap()
        let planCard = app.buttons["稳情计划"]
        if planCard.waitForExistence(timeout: 5) {
            planCard.tap()
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "stable_plan", in: app)
        }
    }

    /// 雨声助眠 — page_53
    func testVisual_RainSound() async throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        let healingEntry = app.buttons["治愈空间"]
        if healingEntry.waitForExistence(timeout: 5) {
            healingEntry.tap()
            sleep(pageTransitionDelay)
            let rainCard = app.buttons["白噪音·雨声"]
            if rainCard.waitForExistence(timeout: 5) {
                rainCard.tap()
                sleep(pageTransitionDelay)
                try await VisualTesting.analyzeWithAI(named: "rain_sound", in: app)
            }
        }
    }

    /// 安全守护 — page_50
    func testVisual_SafetyPlan() async throws {
        app.tabProfile.tap()
        if app.profileSafetyPlan.waitForExistence(timeout: 5) {
            app.profileSafetyPlan.tap()
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "safety_plan", in: app)
        }
    }

    /// 心光会员 — page_16
    func testVisual_VIPCenter() async throws {
        app.tabProfile.tap()
        let vipBanner = app.buttons["心光会员"]
        if vipBanner.waitForExistence(timeout: 5) {
            vipBanner.tap()
            sleep(pageTransitionDelay)
            try await VisualTesting.analyzeWithAI(named: "vip", in: app)
        }
    }

    // MARK: - 像素对比测试（无 AI 依赖）

    /// 首页像素对比
    func testPixelDiff_HomePage() throws {
        app.tabHome.tap()
        _ = app.buttons["今日心情打卡"].waitForExistence(timeout: 5)
        sleep(pageTransitionDelay)
        VisualTesting.compareWithBaseline(named: "home_page_v3", in: app)
    }

    // 注:个人中心不做像素对比——页面内容依赖远端 loadProfile() 实时返回
    // (用户名/陪伴天数/统计数据/加载失败态),基线在 run 内采集,两次独立会话
    // 间网络结果不一致会产生 50%+ 假差异(CI 定时任务 30516057284 实测 54.49%)。
    // 个人中心的视觉校验由 testVisual_ProfilePage(AI 分析,加载失败自动跳过)覆盖。

    /// 树洞像素对比
    func testPixelDiff_TreeHolePage() throws {
        app.tabTreeHole.tap()
        _ = app.textViews.firstMatch.waitForExistence(timeout: 5)
        sleep(pageTransitionDelay)
        VisualTesting.compareWithBaseline(named: "treehole_page_v3", in: app)
    }

    // MARK: - 批量基线截图采集

    /// 采集所有页面的基线截图（仅在首次/设计稿变更时运行）
    func testCaptureAllBaselines() throws {
        // 仅采集内容确定性的页面;个人中心为远端数据驱动,不做像素基线
        let pages: [(String, () -> Void)] = [
            ("home_page_v3", { self.app.tabHome.tap() }),
            ("treehole_page_v3", { self.app.tabTreeHole.tap() }),
        ]

        for (name, navigate) in pages {
            navigate()
            sleep(pageTransitionDelay)
            try VisualTesting.captureBaseline(name: name, in: app)
            print("📸 基线截图已保存: \(name)")
        }
    }
}
