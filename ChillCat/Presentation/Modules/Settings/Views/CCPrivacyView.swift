import SwiftUI

struct CCPrivacyView: View {
    @State private var viewModel = CCSettingsViewModel()

    var body: some View {
        List {
            Section("情绪数据") {
                Toggle("展示情绪状态", isOn: Binding(
                    get: { viewModel.showMood },
                    set: { viewModel.showMood = $0 }
                ))
                Toggle("公开情绪日记", isOn: Binding(
                    get: { viewModel.showJournal },
                    set: { viewModel.showJournal = $0 }
                ))
            }
            Section("数据收集") {
                Toggle("允许匿名数据收集", isOn: Binding(
                    get: { viewModel.allowDataCollection },
                    set: { viewModel.allowDataCollection = $0 }
                ))
                Text("用于改善绪安的情绪分析准确度，不包含个人身份信息").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
            }
            Section("加密") {
                Label("加密", systemImage: "lock.shield.fill").foregroundColor(Color(hex: "66BB6A"))
                Text("所有日记和语音数据均已端到端加密存储").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
            }
            Section {
                Label("匿名已开启", systemImage: "theatermasks.fill").foregroundColor(Color(hex: "5A7A8A"))
                Button("切换为实名") { viewModel.initiateRealNameFlow() }
                    .foregroundColor(Color(hex: "E57373"))
            }
        }
        .navigationTitle("隐私设置")
        .background(AppTheme.background)
    }
}
