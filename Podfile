# 绪安 ChillCat v3.0 — CocoaPods 依赖管理
# 从 Swift Package Manager 迁移至 CocoaPods

platform :ios, '17.0'
use_frameworks!

target 'ChillCat' do
  # ── 网络层 ──
  # Alamofire: 请求链、自动重试、响应校验、日志拦截器
  pod 'Alamofire', '~> 5.9'

  # ── 图片加载 ──
  # Kingfisher: 异步缓存、GIF、渐进式JPEG、SwiftUI 原生支持
  pod 'Kingfisher', '~> 8.0'

  # ── 安全存储 ──
  # KeychainAccess: Secure Enclave、生物认证、iCloud 同步
  pod 'KeychainAccess', '~> 4.2'

  # ── 动画引擎 ──
  # Lottie: Airbnb 动画引擎
  pod 'lottie-ios', '~> 4.6'

  # ── UI 调试工具（仅 Debug） ──
  pod 'LookinServer', :configurations => ['Debug']

  # ── 测试 Target ──
  target 'ChillCatTests' do
    inherit! :search_paths
  end

  target 'ChillCatUITests' do
    inherit! :search_paths
  end
end
