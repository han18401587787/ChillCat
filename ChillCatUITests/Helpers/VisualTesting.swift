import XCTest
import Foundation

/// 视觉回归测试引擎
/// 截取屏幕快照，与基线比对像素差异
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
