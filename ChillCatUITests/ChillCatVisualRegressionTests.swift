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

final class ChillCatVisualRegressionTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["-UITEST_SKIP_WELCOME", "-UITEST_AUTO_LOGIN"]
        let apiURL = ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "http://81.70.178.249:8080"
        app.launchEnvironment = ["CHILLCAT_API_URL": apiURL]
        app.launch()
        _ = app.tabHome.waitForExistence(timeout: 15)
    }

    // MARK: - 🔍 环境自检

    func test_EnvironmentCheck() throws {
        CCDiagnosticHelper.checkEnvironment()
    }

    // MARK: - Tab 页面视觉校验

    /// 首页 — page_18
    func testVisual_HomePage() async throws {
        app.tabHome.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(
            named: "home",
            in: app,
            checks: ["all_elements", "no_overlap", "layout_integrity"]
        )
    }

    /// 树洞 — page_19
    func testVisual_TreeHolePage() async throws {
        app.tabTreeHole.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(
            named: "treehole",
            in: app,
            checks: ["all_elements", "readable_text", "no_overlap"]
        )
    }

    /// 共鸣墙 — page_20
    func testVisual_ResonanceWallPage() async throws {
        app.tabTreeHole.tap() // 共鸣墙可能在树洞Tab下
        sleep(2)
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
            sleep(2)
            try await VisualTesting.analyzeWithAI(named: "healing", in: app)
        }
    }

    /// 个人中心 — page_22
    func testVisual_ProfilePage() async throws {
        app.tabProfile.tap()
        sleep(2)
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
            sleep(2)
            try await VisualTesting.analyzeWithAI(named: "emotion_decoder", in: app)
        }
    }

    /// 情绪记录 — page_36
    func testVisual_EmotionRecord() async throws {
        app.tabHome.tap()
        // 点击打卡按钮进入情绪记录
        let checkinBtn = app.buttons["今日心情打卡"]
        if checkinBtn.waitForExistence(timeout: 5) {
            checkinBtn.tap()
            sleep(2)
            try await VisualTesting.analyzeWithAI(named: "emotion_record", in: app)
        }
    }

    /// 打卡成功 — page_45
    func testVisual_CheckinSuccess() async throws {
        app.tabHome.tap()
        let checkinBtn = app.buttons["今日心情打卡"]
        if checkinBtn.waitForExistence(timeout: 5) {
            checkinBtn.tap()
            sleep(3)
            try await VisualTesting.analyzeWithAI(named: "checkin_success", in: app)
        }
    }

    /// 稳情计划 — page_52
    func testVisual_StablePlan() async throws {
        app.tabHome.tap()
        let planCard = app.buttons["稳情计划"]
        if planCard.waitForExistence(timeout: 5) {
            planCard.tap()
            sleep(2)
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
            sleep(1)
            let rainCard = app.buttons["白噪音·雨声"]
            if rainCard.waitForExistence(timeout: 5) {
                rainCard.tap()
                sleep(2)
                try await VisualTesting.analyzeWithAI(named: "rain_sound", in: app)
            }
        }
    }

    /// 安全守护 — page_50
    func testVisual_SafetyPlan() async throws {
        app.tabProfile.tap()
        if app.profileSafetyPlan.waitForExistence(timeout: 5) {
            app.profileSafetyPlan.tap()
            sleep(2)
            try await VisualTesting.analyzeWithAI(named: "safety_plan", in: app)
        }
    }

    /// 心光会员 — page_16
    func testVisual_VIPCenter() async throws {
        app.tabProfile.tap()
        let vipBanner = app.buttons["心光会员"]
        if vipBanner.waitForExistence(timeout: 5) {
            vipBanner.tap()
            sleep(2)
            try await VisualTesting.analyzeWithAI(named: "vip", in: app)
        }
    }

    // MARK: - 像素对比测试（无 AI 依赖）

    /// 首页像素对比
    func testPixelDiff_HomePage() throws {
        app.tabHome.tap()
        sleep(2)
        VisualTesting.compareWithBaseline(named: "home_page_v3", in: app)
    }

    /// 个人中心像素对比
    func testPixelDiff_ProfilePage() throws {
        app.tabProfile.tap()
        sleep(2)
        VisualTesting.compareWithBaseline(named: "profile_page_v3", in: app)
    }

    /// 树洞像素对比
    func testPixelDiff_TreeHolePage() throws {
        app.tabTreeHole.tap()
        sleep(2)
        VisualTesting.compareWithBaseline(named: "treehole_page_v3", in: app)
    }

    // MARK: - 批量基线截图采集

    /// 采集所有页面的基线截图（仅在首次/设计稿变更时运行）
    func testCaptureAllBaselines() throws {
        let pages: [(String, () -> Void)] = [
            ("home_page_v3", { self.app.tabHome.tap() }),
            ("treehole_page_v3", { self.app.tabTreeHole.tap() }),
            ("profile_page_v3", { self.app.tabProfile.tap() }),
        ]

        for (name, navigate) in pages {
            navigate()
            sleep(2)
            try VisualTesting.captureBaseline(name: name, in: app)
            print("📸 基线截图已保存: \(name)")
        }
    }
}
