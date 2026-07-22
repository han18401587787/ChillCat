import SwiftUI

struct CCDataManagementView: View {
    @State private var viewModel = CCSettingsViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("情绪日记").font(.system(size: 15))
                        Text("\(viewModel.moodDiaryCount) · \(viewModel.moodDiarySize)")
                            .font(.system(size: 12)).foregroundColor(Color.xuanTextTertiary)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportMoodDiary() }
                        .font(.system(size: 13)).foregroundColor(Color.xuanApricotDark)
                        .accessibilityIdentifier("data_mgmt_export_mood_diary")
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("语音备忘").font(.system(size: 15))
                        Text("\(viewModel.voiceMemoCount) · \(viewModel.voiceMemoSize)")
                            .font(.system(size: 12)).foregroundColor(Color.xuanTextTertiary)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportVoiceMemo() }
                        .font(.system(size: 13)).foregroundColor(Color.xuanApricotDark)
                        .accessibilityIdentifier("data_mgmt_export_voice_memo")
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("树洞帖子").font(.system(size: 15))
                        Text("\(viewModel.treeHoleCount) · \(viewModel.treeHoleSize)")
                            .font(.system(size: 12)).foregroundColor(Color.xuanTextTertiary)
                    }
                    Spacer()
                    Button("导出") { viewModel.exportTreeHolePosts() }
                        .font(.system(size: 13)).foregroundColor(Color.xuanApricotDark)
                        .accessibilityIdentifier("data_mgmt_export_tree_hole")
                }
            } header: { Text("数据存储") }

            Section {
                Button("清除缓存") { viewModel.clearCache() }
                    .foregroundColor(Color.xuanTextPrimary)
                    .accessibilityIdentifier("data_mgmt_clear_cache")
                Button("导出所有数据") { viewModel.exportAllData() }
                    .foregroundColor(Color.xuanApricotDark)
                    .accessibilityIdentifier("data_mgmt_export_all")
            }

            Section {
                Button("删除所有情绪日记", role: .destructive) { viewModel.deleteAllMoodDiary() }
                    .accessibilityIdentifier("data_mgmt_delete_mood_diary")
                Button("删除所有树洞帖子", role: .destructive) { viewModel.deleteAllTreeHolePosts() }
                    .accessibilityIdentifier("data_mgmt_delete_tree_hole")
            } header: { Text("危险操作") }
        }
        .navigationTitle("数据管理")
        .background(Color.xuanApricotBg)
        .task { await viewModel.loadDataMetrics() }
    }
}
