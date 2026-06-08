import SwiftUI

struct CCDataManagementView: View {
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("情绪日记").font(.system(size: 15))
                        Text("28 条记录 · 约 2.3 MB").font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") {}.font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("语音备忘").font(.system(size: 15))
                        Text("3 条记录 · 约 4.1 MB").font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") {}.font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("树洞帖子").font(.system(size: 15))
                        Text("12 条记录 · 约 0.5 MB").font(.system(size: 12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Button("导出") {}.font(.system(size: 13)).foregroundColor(Color(hex: "5A7A8A"))
                }
            } header: { Text("数据存储") }

            Section {
                Button("清除缓存") {}.foregroundColor(theme.textPrimary)
                Button("导出所有数据") {}.foregroundColor(Color(hex: "5A7A8A"))
            }

            Section {
                Button("删除所有情绪日记", role: .destructive) {}
                Button("删除所有树洞帖子", role: .destructive) {}
            } header: { Text("危险操作") }
        }
        .navigationTitle("数据管理")
        .background(theme.background)
    }
}
