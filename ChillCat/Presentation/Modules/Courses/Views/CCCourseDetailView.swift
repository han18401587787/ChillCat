import SwiftUI
struct CCCourseDetailView: View {
    let course: CCXuanAPI.CourseItem
    @Environment(\.ccAppTheme) private var theme
    @State private var progress = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                RoundedRectangle(cornerRadius: theme.radiusMD).fill(Color(hex:"D4C8E8").opacity(0.3)).frame(height: 180).overlay(
                    Image(systemName: "book.pages.fill").font(.system(size:48)).foregroundColor(Color(hex:"5A7A8A"))
                )
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text(course.title).font(.system(size:22,weight:.bold))
                    HStack(spacing:8) {
                        Text(course.tag).font(.system(size:12)).foregroundColor(Color(hex:"5A7A8A")).padding(.horizontal,8).padding(.vertical,2).background(Color(hex:"B8D4E3").opacity(0.3)).cornerRadius(4)
                        Text("\(course.duration/60) 分钟").font(.system(size:12)).foregroundColor(theme.textMuted)
                    }
                }
                Divider()
                Text(course.description).font(.system(size:15)).lineSpacing(6).foregroundColor(theme.textSecondary)
                VStack(spacing: theme.spacingSM) {
                    ProgressView(value: progress).tint(Color(hex:"5A7A8A"))
                    HStack{ Text("\(Int(progress*100))% 完成").font(.system(size:12)).foregroundColor(theme.textMuted); Spacer() }
                }
                Button(action: { withAnimation { progress = min(1, progress + 0.25) } }) {
                    Text(progress >= 1 ? "已完成" : "标记进展").fontWeight(.medium).foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14).background(progress>=1 ? Color(hex:"66BB6A") : Color(hex:"5A7A8A")).cornerRadius(theme.radiusMD)
                }
            }.padding()
        }.background(theme.background).navigationTitle("课程详情")
    }
}
