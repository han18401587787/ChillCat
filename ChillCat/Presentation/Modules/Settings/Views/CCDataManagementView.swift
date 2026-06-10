import SwiftUI

struct CCDataManagementView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var viewModel = CCSettingsViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("情绪日记").font(.system(size: 15))
                        Text("\(viewModel.moodDiaryCount) · \(viewModel.moodDiarySize)")
                            .font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportMoodDiary() }
                        .font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("语音备忘").font(.system(size: 15))
                        Text("\(viewModel.voiceMemoCount) · \(viewModel.voiceMemoSize)")
                            .font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportVoiceMemo() }
                        .font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("树洞帖子").font(.system(size: 15))
                        Text("\(viewModel.treeHoleCount) · \(viewModel.treeHoleSize)")
                            .font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportTreeHolePosts() }
                        .font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
            } header: { Text("数据存储") }

            Section {
                Button("清除缓存") { viewModel.clearCache() }
                    .foregroundColor(theme.textPrimary)
                Button("导出所有数据") { viewModel.exportAllData() }
                    .foregroundColor(Color(hex: "5A7A8A"))
            }

            Section {
                Button("删除所有情绪日记", role: .destructive) { viewModel.deleteAllMoodDiary() }
                Button("删除所有树洞帖子", role: .destructive) { viewModel.deleteAllTreeHolePosts() }
            } header: { Text("危险操作") }
        }
        .navigationTitle("数据管理")
        .background(theme.background)
        .task { await viewModel.loadDataMetrics() }
    }
}
