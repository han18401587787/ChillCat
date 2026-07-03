import SwiftUI
struct CCCourseDetailView: View {
    let course: CCXuanAPI.CourseItem
    @State private var progress = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: XuanSpacing.lg) {
                RoundedRectangle(cornerRadius: XuanRadius.md).fill(Color(hex: "A085C6").opacity(0.3)).frame(height: 180).overlay(
                    Image(systemName: "book.pages.fill").font(.system(size:48)).foregroundColor(Color.xuanApricotDark)
                )
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text(course.title ?? "").font(.system(size:22,weight:.bold))
                    HStack(spacing:8) {
                        Text(course.tag ?? "").font(.system(size:12)).foregroundColor(Color.xuanApricotDark).padding(.horizontal,8).padding(.vertical,2).background(Color.xuanInfo.opacity(0.3)).cornerRadius(4)
                        Text("\((course.duration ?? 0) / 60) 分钟").font(.system(size:12)).foregroundColor(Color.xuanTextTertiary)
                    }
                }
                Divider()
                Text(course.description ?? "").font(.system(size:15)).lineSpacing(6).foregroundColor(Color.xuanTextSecondary)
                VStack(spacing: XuanSpacing.sm) {
                    ProgressView(value: progress).tint(Color.xuanApricotDark)
                    HStack{ Text("\(Int(progress*100))% 完成").font(.system(size:12)).foregroundColor(Color.xuanTextTertiary); Spacer() }
                }
                Button(action: { withAnimation { progress = min(1, progress + 0.25) } }) {
                    Text(progress >= 1 ? "已完成" : "标记进展").fontWeight(.medium).foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14).background(progress>=1 ? Color.xuanMint : Color.xuanApricotDark).cornerRadius(XuanRadius.md)
                }
            }.padding()
        }.background(Color.xuanApricotBg).navigationTitle("课程详情")
    }
}
