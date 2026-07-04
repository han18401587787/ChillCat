// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChillCat",
    platforms: [.iOS(.v17)],
    dependencies: [
        // 网络层：替代 URLSession，提供请求链、自动重试、响应校验、日志拦截器
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        // 图片加载：异步缓存、GIF、渐进式JPEG、SwiftUI 原生 .kfImage()
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        // Keychain：Secure Enclave、生物认证、iCloud 同步、访问级别控制
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
        // Lottie 动画引擎
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.6.1"),
        // Lookin UI 调试工具（仅 Debug 生效）
        .package(url: "https://github.com/QMUI/LookinServer.git", branch: "develop"),
    ],
    targets: [
        .target(
            name: "ChillCat",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "LookinServer", package: "LookinServer"),
            ]
        )
    ]
)
// Test dependencies (add to Xcode test target)
// ViewInspector: https://github.com/nalexn/ViewInspector
// SnapshotTesting: https://github.com/pointfreeco/swift-snapshot-testing
