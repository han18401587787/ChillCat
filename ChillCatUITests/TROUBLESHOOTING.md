# UI 测试常见问题

## 1. 横屏闪退

**原因:** App 未适配横屏布局，测试旋转到 landscape 时 crash。

**修复:** Info.plist 已锁定 `UIInterfaceOrientationPortrait`。测试中通过 `XCUIDevice.shared.orientation = .portrait` 强制竖屏。

## 2. 卡在登录页

**原因:** 模拟器 localhost 无法访问远程 `api.chillcatgo.com`。

**解决:**
- **方案 A（推荐）:** WelcomeView 已有离线兜底 → 点击按钮后本地直接跳转。测试 timeout 已延长到 15s。
- **方案 B:** 修改 `CCAppEnvironment.swift` 临时指回 `http://localhost:8080`，本地启动服务端 Docker。
- **方案 C:** 服务端已开放 80 端口后，模拟器可直连 `http://api.chillcatgo.com`。

## 3. 测试断言失败但 App 实际正常

**原因:** 网络延迟/动画未完成。

**解决:** 增加 `sleep(2)` 或 `waitForExistence(timeout: 15)`。

## 4. 视觉回归测试首次运行失败

**原因:** 基线截图不存在。

**解决:** 首次运行自动创建基线，重新运行即可通过。

## 5. Xcode 覆盖了我的测试文件

**原因:** Xcode 创建 UI Test Target 时会生成模板文件。

**解决:** `git checkout HEAD -- ChillCatUITests/` 恢复后重新拖入 Xcode target。
