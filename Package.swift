// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChillCat",
    platforms: [.iOS(.v17)],
    dependencies: [
        // 图片异步加载与缓存 — GitHub 38k stars，SwiftUI 原生支持
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        // Lottie 动画 — 用于品牌动效、冥想引导、打卡庆祝
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.0"),
    ],
    targets: [
        .target(
            name: "ChillCat",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Lottie", package: "lottie-ios"),
            ]
        )
    ]
)
