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
  # 两个 target 运行方式不同,继承方式必须区别对待:
  #
  # ChillCatTests(单元测试): TEST_HOST=ChillCat.app, 注入宿主进程运行,
  # framework 由宿主 App 提供 → 只需 :search_paths。
  # 误用 :complete 会让 CocoaPods 给托管包加 Embed 阶段,
  # 构建时报 "Build input file cannot be found: .../PlugIns/ChillCatTests.xctest/ChillCatTests"
  # (CI #269-#272 exit 65、0 测试运行的根因)
  target 'ChillCatTests' do
    inherit! :search_paths
  end

  # ChillCatUITests(UI 测试): 独立 runner 进程, 必须自带 framework 副本,
  # 否则运行时 dlopen 找不到 Alamofire.framework
  # (Library not loaded: @rpath/Alamofire.framework) → 需要 :complete
  target 'ChillCatUITests' do
    inherit! :complete
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
  installer.aggregate_targets.each do |target|
    target.user_project.native_targets.each do |native_target|
      native_target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
