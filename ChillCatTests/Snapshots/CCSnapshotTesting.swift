import XCTest
import SwiftUI

/// 快照测试引擎 — 基于 SwiftUI ImageRenderer
/// 无需第三方依赖，直接支持 CI 环境
struct CCSnapshotTesting {

    /// 快照存储目录
    static var referenceDir: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("References")
    }

    /// 失败差异存储目录
    static var failureDir: URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapshotFailures")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// 允许的最大像素差异（0~1）
    static var maxPixelDiff: Double = 0.005 // 0.5%

    // MARK: - 快照比对

    /// 截取视图快照并与基线比对
    /// - 首次运行自动创建基线
    /// - 差异超阈值时自动保存差异图
    static func assertSnapshot<V: View>(
        of view: V,
        named name: String,
        size: CGSize = CGSize(width: 390, height: 844),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        renderer.proposedSize = .init(size)

        guard let uiImage = renderer.uiImage,
              let currentData = uiImage.pngData() else {
            XCTFail("快照渲染失败: \(name)", file: file, line: line)
            return
        }

        let refURL = referenceDir.appendingPathComponent("\(name).png")
        try? FileManager.default.createDirectory(at: referenceDir, withIntermediateDirectories: true)

        guard let refData = try? Data(contentsOf: refURL),
              let refImage = UIImage(data: refData) else {
            // 基线不存在 → 自动创建
            try? currentData.write(to: refURL)
            XCTFail("📸 基线已创建: \(name).png，请重新运行测试", file: file, line: line)
            return
        }

        let diff = pixelDiff(refImage, uiImage)
        if diff > maxPixelDiff {
            // 保存差异截图
            let failURL = failureDir.appendingPathComponent("\(name)_diff.png")
            try? currentData.write(to: failURL)
            XCTFail("📸 快照差异 \(String(format: "%.2f", diff * 100))% > \(String(format: "%.1f", maxPixelDiff * 100))%", file: file, line: line)
        }
    }

    // MARK: - 像素比对

    private static func pixelDiff(_ img1: UIImage, _ img2: UIImage) -> Double {
        guard let cg1 = img1.cgImage, let cg2 = img2.cgImage else { return 1.0 }
        let w = min(cg1.width, cg2.width), h = min(cg1.height, cg2.height)
        guard w > 0, h > 0 else { return 1.0 }

        let ctx1 = makeContext(w: w, h: h, image: cg1)
        let ctx2 = makeContext(w: w, h: h, image: cg2)
        guard let data1 = ctx1?.data, let data2 = ctx2?.data else { return 1.0 }

        let threshold: Int32 = 10
        var diffCount = 0, total = w * h
        let p1 = data1.bindMemory(to: UInt8.self, capacity: total * 4)
        let p2 = data2.bindMemory(to: UInt8.self, capacity: total * 4)
        for i in stride(from: 0, to: total * 4, by: 4) {
            if abs(Int32(p1[i]) - Int32(p2[i])) > threshold ||
               abs(Int32(p1[i+1]) - Int32(p2[i+1])) > threshold ||
               abs(Int32(p1[i+2]) - Int32(p2[i+2])) > threshold { diffCount += 1 }
        }
        return Double(diffCount) / Double(total)
    }

    private static func makeContext(w: Int, h: Int, image: CGImage) -> CGContext? {
        let ctx = CGContext(data: nil, width: w, height: h,
                            bitsPerComponent: 8, bytesPerRow: w * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        ctx?.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return ctx
    }
}
