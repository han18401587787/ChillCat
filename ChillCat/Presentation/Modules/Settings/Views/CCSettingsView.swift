import SwiftUI

struct CCSettingsView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(CCThemeManager.self) private var themeManager
    @State private var notificationsEnabled = true

    var body: some View {
        List {
            Section("外观") {
                Button(action: { themeManager.isDarkMode.toggle() }) {
                    Label("暗色模式", systemImage: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                }.foregroundColor(.primary)
            }
            Section("通知") {
                Toggle(isOn: $notificationsEnabled) { Label("消息推送", systemImage: "bell.fill") }
            }
            Section("关于") {
                Label("版本 2.0", systemImage: "info.circle")
                Button(action: { coordinator.navigate(to: .privacy) }) { Label("隐私设置", systemImage: "lock.fill").foregroundColor(.primary) }
                Label("用户协议", systemImage: "doc.text.fill")
                Button(action: { coordinator.navigate(to: .faq) }) { Label("常见问题", systemImage: "questionmark.circle.fill").foregroundColor(.primary) }
                Label("意见反馈", systemImage: "envelope.fill")
            }
            Section("数据") {
                Button("数据管理") { coordinator.navigate(to: .dataManagement) }
                Button("注销账号", role: .destructive) { coordinator.navigate(to: .deleteAccount) }
            }
        }
        .navigationTitle("设置")
    }
}
