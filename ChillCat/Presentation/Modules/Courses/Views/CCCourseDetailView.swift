import SwiftUI
struct CCCourseDetailView: View {
    let course: CCXuanAPI.CourseItem
    @State private var progress = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                RoundedRectangle(cornerRadius: AppRadius.md).fill(AppTheme.warmPurple.opacity(0.3)).frame(height: 180).overlay(
                    Image(systemName: "book.pages.fill").font(.system(size:48)).foregroundColor(AppTheme.primaryDark)
                )
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(course.title).font(.system(size:22,weight:.bold))
                    HStack(spacing:8) {
                        Text(course.tag).font(.system(size:12)).foregroundColor(AppTheme.primaryDark).padding(.horizontal,8).padding(.vertical,2).background(AppTheme.info.opacity(0.3)).cornerRadius(4)
                        Text("\(course.duration/60) 分钟").font(.system(size:12)).foregroundColor(AppTheme.textMuted)
                    }
                }
                Divider()
                Text(course.description).font(.system(size:15)).lineSpacing(6).foregroundColor(AppTheme.textSecondary)
                VStack(spacing: AppSpacing.sm) {
                    ProgressView(value: progress).tint(AppTheme.primaryDark)
                    HStack{ Text("\(Int(progress*100))% 完成").font(.system(size:12)).foregroundColor(AppTheme.textMuted); Spacer() }
                }
                Button(action: { withAnimation { progress = min(1, progress + 0.25) } }) {
                    Text(progress >= 1 ? "已完成" : "标记进展").fontWeight(.medium).foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14).background(progress>=1 ? AppTheme.accentMint : AppTheme.primaryDark).cornerRadius(AppRadius.md)
                }
            }.padding()
        }.background(AppTheme.background).navigationTitle("课程详情")
    }
}
