import SwiftUI

struct CCCoursesView: View {
    @State private var viewModel = CCCoursesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: XuanSpacing.lg) {
                Text("小课堂").font(.system(size: 24, weight: .bold))
                switch viewModel.loadState {
                case .loading:
                    CCSkeletonList(count: 6)
                case .loaded:
                    ForEach(viewModel.categories, id: \.name) { cat in
                        categorySection(title: cat.name, icon: cat.icon, color: cat.color, courses: cat.items)
                    }
                case .empty:
                    emptyState
                case .error(let message):
                    CCErrorView(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: message])) {
                        await viewModel.loadCourses()
                    }
                }
            }.padding()
        }
        .background(Color.xuanApricotBg).navigationTitle("小课堂")
        .task { await viewModel.loadCourses() }
    }

    private var emptyState: some View {
        VStack(spacing: XuanSpacing.md) {
            Spacer().frame(height: 80)
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundColor(Color.xuanTextTertiary)
            Text("暂无课程")
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    func categorySection(title: String, icon: String, color: Color, courses: [CCXuanAPI.CourseItem]) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            HStack { Image(systemName: icon).foregroundColor(color); Text(title).font(.system(size: 18, weight: .semibold)) }
            ForEach(courses) { course in
                NavigationLink(value: CCAppRoute.courseDetail(course)) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.title ?? "").font(.system(size: 15, weight: .medium))
                            HStack(spacing: 8) {
                                Text(course.tag ?? "").font(.system(size: 11)).foregroundColor(Color.xuanApricotDark)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(Color.xuanInfo.opacity(0.3)).cornerRadius(4)
                                Text("\((course.duration ?? 0) / 60) 分钟").font(.system(size: 11)).foregroundColor(Color.xuanTextTertiary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(Color.xuanTextTertiary)
                    }.padding().background(Color.xuanWhite).cornerRadius(XuanRadius.md)
                }
            }
        }
    }
}
