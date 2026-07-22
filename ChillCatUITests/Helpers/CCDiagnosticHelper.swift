//
//  CCDiagnosticHelper.swift
//  绪安 v3.0 — 测试诊断工具
//
//  功能: 测试失败时自动采集诊断信息，帮助快速定位根因
//  - 环境自检: API连通性 / 进程环境变量
//  - 页面快照: 截图 + 元素统计
//  - 元素诊断: 精简关键词搜索（CI 安全，避免 allElementsBoundByIndex 逐个遍历）
//
//  CI 安全策略:
//  - 不使用 allElementsBoundByIndex 逐个遍历（每个元素一次 RPC，headless 模拟器极易超时）
//  - 仅使用 firstMatch / count / XCUIElementQuery 的 contains 等批量操作
//  - 截图使用 autoreleasepool + try? 保护

import XCTest

struct CCDiagnosticHelper {

    // MARK: - 环境自检 (在所有测试前运行)

    /// 检查 API 连通性和环境配置
    static func checkEnvironment(file: StaticString = #file, line: UInt = #line) {
        let apiURL = resolveAPIURL()
        let envVars = ProcessInfo.processInfo.environment

        print("""
        ╔══════════════════════════════════════════╗
        ║        🔍 环境自检                        ║
        ╠══════════════════════════════════════════╣
        ║  API URL: \(apiURL.padding(toLength: 36, withPad: " ", startingAt: 0))║
        ║  CI:      \(envVars["CI"]?.padding(toLength: 36, withPad: " ", startingAt: 0) ?? "not set".padding(toLength: 36, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════════════════╝
        """)

        // 同步 HEAD 请求检查连通性
        let semaphore = DispatchSemaphore(value: 0)
        var reachable = false
        var statusCode = 0

        let url = URL(string: "\(apiURL)/api/v1/vision/analyze")!
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                reachable = true
            }
            if let error = error {
                print("   ⚠️  网络检查失败: \(error.localizedDescription)")
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .now() + 6)

        if reachable {
            print("   ✅ API 可达 (HTTP \(statusCode))")
        } else {
            let msg = """
            ❌ API 不可达: \(apiURL)
               可能原因:
               1. 服务器未启动
               2. 网络不通 (CI 防火墙?)
               3. URL 配置错误
               当前配置: CHILLCAT_API_URL=\(ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "未设置")
               实际使用: \(apiURL)
            """
            print(msg)
            XCTFail("API 不可达 — 后续视觉测试将全部失败", file: file, line: line)
        }
    }

    // MARK: - 页面元素诊断（CI 安全精简版）

    /// 诊断元素查找失败的原因，输出精简页面快照
    /// CI 安全：避免 allElementsBoundByIndex 逐个遍历，防止 headless 模拟器超时崩溃
    static func diagnose(
        page: String,
        expectedElement: String,
        app: XCUIApplication,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        print("""
        
        ╔══════════════════════════════════════════╗
        ║   🩺 诊断报告: \(page)                      ║
        ║   期望元素: \(expectedElement.padding(toLength: 28, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════════════════╝
        """)

        // 1. 截图 (CI 安全)
        autoreleasepool {
            if let screenshot = try? app.screenshot() {
                let screenshotPath = "/tmp/diag_\(page)_\(Date().timeIntervalSince1970).png"
                try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: screenshotPath))
                print("   📸 截图: \(screenshotPath)")
            } else {
                print("   ⚠️  截图失败 (CI 环境限制)")
            }
        }

        // 2. App 状态检查
        guard app.exists else {
            print("   ⚠️  App 不存在，跳过元素诊断")
            print("   ╚══════════════════════════════════════════╝\n")
            return
        }

        // 3. 元素统计（仅 count，不逐个遍历）
        let stCount = app.staticTexts.count
        let btnCount = app.buttons.count
        let tfCount = app.textFields.count
        let tvCount = app.textViews.count
        print("   📊 元素统计: staticTexts=\(stCount) buttons=\(btnCount) textFields=\(tfCount) textViews=\(tvCount)")

        // 4. 关键词匹配（使用 XCUIElementQuery 的 matching 而非逐个遍历）
        let keywords = expectedElement.components(separatedBy: CharacterSet(charactersIn: "「」"))
            .filter { $0.count >= 2 }
        
        for kw in keywords {
            let stMatch = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", kw))
            let btnMatch = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", kw))
            if stMatch.count > 0 {
                print("   🔍 staticText 含'\(kw)': \(stMatch.count) 个匹配")
            }
            if btnMatch.count > 0 {
                print("   🔍 button 含'\(kw)': \(btnMatch.count) 个匹配")
            }
        }

        // 5. 直接精确查找
        let exactST = app.staticTexts[expectedElement].firstMatch
        let exactBtn = app.buttons[expectedElement].firstMatch
        print("   🎯 精确匹配: staticText.exists=\(exactST.exists) button.exists=\(exactBtn.exists)")

        // 6. 导航栏检查
        let navBar = app.navigationBars.firstMatch
        if navBar.exists {
            print("   📱 当前导航栏: \"\(navBar.identifier)\"")
        }

        // 7. TabBar 检查
        let selectedTab = app.tabBars.buttons.element(boundBy: 0)
        print("   📑 TabBar 可见: \(app.tabBars.firstMatch.exists)")

        print("   ╚══════════════════════════════════════════╝\n")
    }

    // MARK: - 按钮元素诊断

    /// 诊断按钮查找失败
    static func diagnoseButton(
        page: String,
        buttonLabel: String,
        app: XCUIApplication,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        diagnose(page: page, expectedElement: buttonLabel, app: app, file: file, line: line)

        // 检查是否有同名的 staticText (说明是 Text+tapGesture 伪按钮)
        let asText = app.staticTexts[buttonLabel].firstMatch
        if asText.exists && asText.isHittable {
            print("   🐛 发现伪按钮! \"\(buttonLabel)\" 是 StaticText 而非 Button — 应该用 Button 包裹")
        }
    }

    // MARK: - 内部工具

    /// 解析实际使用的 API URL
    static func resolveAPIURL() -> String {
        return ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "http://81.70.178.249:8080"
    }
}
