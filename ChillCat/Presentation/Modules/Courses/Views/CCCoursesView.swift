import SwiftUI

struct CCCoursesView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var viewModel = CCCoursesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
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
        .background(theme.background).navigationTitle("小课堂")
        .task { await viewModel.loadCourses() }
    }

    private var emptyState: some View {
        VStack(spacing: theme.spacingMD) {
            Spacer().frame(height: 80)
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundColor(theme.textMuted)
            Text("暂无课程")
                .font(.system(size: 15))
                .foregroundColor(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    func categorySection(title: String, icon: String, color: Color, courses: [CCXuanAPI.CourseItem]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            HStack { Image(systemName: icon).foregroundColor(color); Text(title).font(.system(size: 18, weight: .semibold)) }
            ForEach(courses) { course in
                NavigationLink(value: CCAppRoute.courseDetail(course)) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.title).font(.system(size: 15, weight: .medium))
                            HStack(spacing: 8) {
                                Text(course.tag).font(.system(size: 11)).foregroundColor(Color(hex: "5A7A8A"))
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(Color(hex: "B8D4E3").opacity(0.3)).cornerRadius(4)
                                Text("\(course.duration / 60) 分钟").font(.system(size: 11)).foregroundColor(theme.textMuted)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(theme.textMuted)
                    }.padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
                }
            }
        }
    }
}
