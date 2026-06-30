//
//  CCDiagnosticHelper.swift
//  绪安 v3.0 — 测试诊断工具
//
//  功能: 测试失败时自动采集诊断信息，帮助快速定位根因
//  - 环境自检: API连通性 / 进程环境变量
//  - 页面快照: 截图 + 视图层级树 + 所有可见元素列表
//  - 元素诊断: 模糊搜索 + 遮挡检测 + 渲染类型检查

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

    // MARK: - 页面元素诊断

    /// 诊断元素查找失败的原因，输出完整页面快照
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

        // 1. 截图 (可能在某些 CI 环境失败，包裹在 autoreleasepool 中防止内存暴涨)
        autoreleasepool {
            if let screenshot = try? app.screenshot() {
                let screenshotPath = "/tmp/diag_\(page)_\(Date().timeIntervalSince1970).png"
                try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: screenshotPath))
                print("   📸 截图: \(screenshotPath)")
            } else {
                print("   ⚠️  截图失败 (CI 环境限制)")
            }
        }

        // 2. 统计所有可见元素（安全访问，避免 CI headless 环境 crash）
        guard app.exists && app.state == .runningForeground else {
            print("   ⚠️  App 状态异常 (exists=\(app.exists), state=\(app.state.rawValue))，跳过元素诊断")
            print("   ╚══════════════════════════════════════════╝\n")
            return
        }

        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        let allButtons = app.buttons.allElementsBoundByIndex
        let allTextFields = app.textFields.allElementsBoundByIndex
        let allTextViews = app.textViews.allElementsBoundByIndex

        print("   📊 元素统计: staticTexts=\(allStaticTexts.count) buttons=\(allButtons.count) textFields=\(allTextFields.count) textViews=\(allTextViews.count)")

        // 3. 模糊搜索最接近的匹配
        let keywords = expectedElement.components(separatedBy: CharacterSet(charactersIn: "「」"))
            .filter { $0.count >= 2 }
        var candidates: [(String, String, Int)] = [] // (label, type, distance)

        for text in allStaticTexts where text.exists {
            let dist = levenshtein(text.label, expectedElement)
            if dist < expectedElement.count / 2 {
                candidates.append((text.label, "staticText", dist))
            }
        }
        for btn in allButtons where btn.exists {
            let label = btn.label
            let dist = levenshtein(label, expectedElement)
            if dist < expectedElement.count / 2 {
                candidates.append((label, "button", dist))
            }
        }
        // 关键词匹配
        for kw in keywords {
            for text in allStaticTexts where text.exists && text.label.contains(kw) {
                candidates.append((text.label, "staticText(含'\(kw)')", 0))
            }
            for btn in allButtons where btn.exists && btn.label.contains(kw) {
                candidates.append((btn.label, "button(含'\(kw)')", 0))
            }
        }

        candidates.sort { $0.2 < $1.2 }
        if !candidates.isEmpty {
            print("   🔍 最接近的匹配 (前5):")
            for (label, type, dist) in candidates.prefix(5) {
                print("      [\(type)] \"\(label)\" (距离=\(dist))")
            }
        } else {
            print("   🔍 未找到任何接近匹配")
        }

        // 4. 列出所有可见文本 (前20个)
        let visibleTexts = allStaticTexts.filter { $0.isHittable }.prefix(20)
        if !visibleTexts.isEmpty {
            print("   📋 可点击文本 (前20):")
            for t in visibleTexts {
                let frame = t.frame
                print("      \"\(t.label)\" @ (\(Int(frame.minX)),\(Int(frame.minY))) \(Int(frame.width))x\(Int(frame.height))")
            }
        }

        // 5. 列出所有可见按钮
        let visibleButtons = allButtons.filter { $0.isHittable }.prefix(15)
        if !visibleButtons.isEmpty {
            print("   📋 可点击按钮 (前15):")
            for b in visibleButtons {
                let frame = b.frame
                print("      \"\(b.label)\" @ (\(Int(frame.minX)),\(Int(frame.minY))) \(Int(frame.width))x\(Int(frame.height))")
            }
        }

        // 6. 遮挡检测
        let target = app.staticTexts[expectedElement].firstMatch
        if target.exists {
            let isCovered = target.frame.minY < 0 || target.frame.maxY > app.frame.height
                || target.frame.minX < 0 || target.frame.maxX > app.frame.width
            if isCovered {
                print("   ⚠️  元素存在但可能被遮挡或超出屏幕: frame=\(target.frame)")
            }
            if !target.isHittable {
                print("   ⚠️  元素存在但不可点击 (isHittable=false)")
            }
        }

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

        // 额外: 检查是否有同名的 staticText (说明是 Text+tapGesture 伪按钮)
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

    /// 编辑距离 (Levenshtein)
    private static func levenshtein(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1), b = Array(s2)
        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dp[i][0] = i }
        for j in 0...b.count { dp[j][0] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                dp[i][j] = a[i-1] == b[j-1]
                    ? dp[i-1][j-1]
                    : min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]) + 1
            }
        }
        return dp[a.count][b.count]
    }
}
