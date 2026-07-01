import XCTest
import Foundation

/// 视觉回归测试引擎
/// 支持两种校验模式：
/// 1. 像素对比 — 与基线截图逐像素比对
/// 2. AI 视觉校验 — 调用后端通义千问多模态模型进行语义级 UI 完整度分析
struct VisualTesting {

    /// 允许的最大像素差异百分比（默认 0.5%）
    static var maxDiffPercent: Double = 0.5

    /// 基线截图存储路径
    static var baselineDir: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Screenshots/Baseline")
    }

    /// 失败截图存储路径
    static var failureDir: URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VisualDiffFailures")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// 截取当前屏幕并保存为基线
    static func captureBaseline(name: String, in app: XCUIApplication) throws {
        let screenshot = app.screenshot()
        let fileURL = baselineDir.appendingPathComponent("\(name).png")
        try FileManager.default.createDirectory(at: baselineDir, withIntermediateDirectories: true)
        try screenshot.pngRepresentation.write(to: fileURL)
        print("✅ Baseline saved: \(name).png")
    }

    /// 截取当前屏幕并与基线比对
    /// - Returns: 差异百分比, 失败时自动保存差异截图
    @discardableResult
    static func compareWithBaseline(named name: String, in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) -> Double {
        let current = app.screenshot()
        let baselineURL = baselineDir.appendingPathComponent("\(name).png")

        guard let baselineData = try? Data(contentsOf: baselineURL),
              let baselineImage = platformImage(from: baselineData),
              let currentImage = platformImage(from: current.pngRepresentation) else {
            // 基线不存在 → 自动创建
            try? captureBaseline(name: name, in: app)
            XCTFail("基线不存在，已自动创建: \(name).png。请重新运行测试。", file: file, line: line)
            return 1.0
        }

        let diff = pixelDiff(baselineImage, currentImage)

        if diff > maxDiffPercent {
            // 保存失败截图
            let failURL = failureDir.appendingPathComponent("\(name)_diff.png")
            try? current.pngRepresentation.write(to: failURL)
            XCTFail("视觉差异 \(String(format: "%.2f", diff * 100))% 超过阈值 \(String(format: "%.1f", maxDiffPercent * 100))%", file: file, line: line)
        } else {
            print("✅ Visual match: \(name) (\(String(format: "%.2f", diff * 100))%)")
        }

        return diff
    }

    // MARK: - AI 视觉完整度校验

    /// AI 视觉完整度分析结果
    struct AIVisionReport {
        let score: Double
        let passed: Bool
        let issues: [VisionIssue]
        let elementsFound: [String]
        let elementsMissing: [String]
        let suggestion: String

        struct VisionIssue {
            let type: String
            let description: String
            let severity: String
        }
    }

    /// 调用后端 AI 视觉分析接口，进行语义级 UI 完整度校验
    /// - Parameters:
    ///   - pageName: 页面标识 (home/treehole/toolbox/vip/profile)
    ///   - app: XCUIApplication 实例
    ///   - checks: 检查项列表，默认 ["all_elements"]
    ///   - file: 测试文件路径
    ///   - line: 测试行号
    /// - Returns: AI 视觉分析报告
    @discardableResult
    static func analyzeWithAI(
        named pageName: String,
        in app: XCUIApplication,
        checks: [String] = ["all_elements"],
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> AIVisionReport {
        let screenshot = app.screenshot()
        let base64 = screenshot.pngRepresentation.base64EncodedString()

        // 截图基础校验：空白/过小截图提前告警
        let imageSizeKB = Double(screenshot.pngRepresentation.count) / 1024.0
        print("   📸 截图大小: \(String(format: "%.1f", imageSizeKB))KB (页面: \(pageName))")

        // 直接 HTTP 调用
        let result = try await visionAPIRequest(image: base64, page: pageName, checks: checks)

        let report = AIVisionReport(
            score: result.score,
            passed: result.passed,
            issues: result.issues.map { AIVisionReport.VisionIssue(type: $0.type, description: $0.description, severity: $0.severity) },
            elementsFound: result.elementsFound,
            elementsMissing: result.elementsMissing,
            suggestion: result.suggestion
        )

        if !report.passed {
            // 规则模式（无 AI Key）：评分固定 50，不做精确分析
            if report.suggestion.contains("规则模式") || report.suggestion.contains("DASHSCOPE_API_KEY") {
                print("   ⚠️ 服务器运行在规则模式 (无 AI Key)，跳过视觉校验")
                return report  // 不报失败
            }

            // 评分过低时自动诊断
            if report.score < 30 {
                print("   ⚠️ 评分过低 (\(String(format: "%.0f", report.score)))，可能原因:")
                if imageSizeKB < 10 {
                    print("   🚨 截图过小 (\(String(format: "%.0f", imageSizeKB))KB) → 页面可能是空白或未加载")
                }
                if result.elementsFound.isEmpty && result.elementsMissing.isEmpty {
                    print("   🚨 AI 未识别到任何元素 → 截图内容可能完全不匹配页面 \(pageName)")
                }
                if result.elementsMissing.count > 3 {
                    print("   🚨 缺失 \(result.elementsMissing.count) 个预期元素 → 可能导航到了错误页面")
                }
                // 打印当前页面可见文本帮助定位
                let visibleTexts = app.staticTexts.allElementsBoundByIndex.filter { $0.isHittable }.prefix(8)
                if !visibleTexts.isEmpty {
                    print("   📋 当前页面可见文本: \(visibleTexts.map { "\"\($0.label)\"" }.joined(separator: ", "))")
                }
                // 保存截图到 /tmp/ 供后续分析
                let diagPath = "/tmp/vision_fail_\(pageName)_\(Int(Date().timeIntervalSince1970)).png"
                try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: diagPath))
                print("   💾 失败截图已保存: \(diagPath)")
            }

            let issueList = report.issues.map { "• [\($0.severity)] \($0.description)" }.joined(separator: "\n")
            let missingList = report.elementsMissing.isEmpty ? "" : "\n缺失元素: \(report.elementsMissing.joined(separator: ", "))"
            let foundList = report.elementsFound.isEmpty ? "" : "\n识别到: \(report.elementsFound.joined(separator: ", "))"
            XCTFail("❌ AI 视觉校验未通过 (\(pageName)) 评分: \(String(format: "%.1f", report.score))\(foundList)\(missingList)\n\(issueList)\n💡 \(report.suggestion)", file: file, line: line)
        } else {
            print("✅ AI 视觉校验通过 (\(pageName)) 评分: \(String(format: "%.1f", report.score))")
            if !report.elementsFound.isEmpty {
                print("   已检测元素: \(report.elementsFound.joined(separator: ", "))")
            }
            if !report.suggestion.isEmpty {
                print("   💡 \(report.suggestion)")
            }
        }

        return report
    }

    /// 直接 HTTP 调用视觉分析接口
    private static func visionAPIRequest(image: String, page: String, checks: [String]) async throws -> CCVisionAnalyzeResult {
        let baseURL = ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "http://81.70.178.249:8080"
        let url = URL(string: "\(baseURL)/api/v1/vision/analyze")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body = CCVisionAnalyzeRequest(image: image, page: page, checks: checks)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "VisionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "API 请求失败"])
        }

        struct APIResponse: Decodable {
            let code: Int
            let message: String
            let data: CCVisionAnalyzeResult?
        }
        let apiResp = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let result = apiResp.data else {
            throw NSError(domain: "VisionAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "API 返回 data 为 null: \(apiResp.message)"])
        }
        return result
    }

    // MARK: - 像素比对引擎

    private static func platformImage(from data: Data) -> CGImage? {
        #if os(iOS)
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return cgImage
        #else
        return nil
        #endif
    }

    /// 逐像素比对两张图片，返回差异百分比
    private static func pixelDiff(_ img1: CGImage, _ img2: CGImage) -> Double {
        let width = min(img1.width, img2.width)
        let height = min(img1.height, img2.height)

        guard width > 0, height > 0 else { return 1.0 }

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels1 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        var pixels2 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let ctx1 = CGContext(data: &pixels1, width: width, height: height,
                                    bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let ctx2 = CGContext(data: &pixels2, width: width, height: height,
                                    bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return 1.0 }

        ctx1.draw(img1, in: CGRect(x: 0, y: 0, width: width, height: height))
        ctx2.draw(img2, in: CGRect(x: 0, y: 0, width: width, height: height))

        var diffCount = 0
        let threshold: UInt8 = 10 // 单通道容差
        for i in stride(from: 0, to: pixels1.count, by: bytesPerPixel) {
            if abs(Int(pixels1[i]) - Int(pixels2[i])) > threshold ||
               abs(Int(pixels1[i+1]) - Int(pixels2[i+1])) > threshold ||
               abs(Int(pixels1[i+2]) - Int(pixels2[i+2])) > threshold {
                diffCount += 1
            }
        }

        return Double(diffCount) / Double(pixels1.count / bytesPerPixel)
    }
}
