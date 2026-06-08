import SwiftUI

struct CCSettingsView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(CCThemeManager.self) private var themeManager
    @State private var notificationsEnabled = true

    var body: some View {
        List {
            Section("外观") {
                Toggle(isOn: $themeManager.isDarkMode) { Label("暗色模式", systemImage: "moon.fill") }
            }
            Section("通知") {
                Toggle(isOn: $notificationsEnabled) { Label("消息推送", systemImage: "bell.fill") }
            }
            Section("关于") {
                Label("版本 2.0", systemImage: "info.circle")
                Label("隐私政策", systemImage: "lock.fill")
                Label("用户协议", systemImage: "doc.text.fill")
                Label("意见反馈", systemImage: "envelope.fill")
            }
            Section("数据") {
                Button("数据管理") {}
                Button("注销账号", role: .destructive) {}
            }
        }
        .navigationTitle("设置")
    }
}
