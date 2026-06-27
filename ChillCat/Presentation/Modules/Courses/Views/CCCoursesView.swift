import SwiftUI

struct CCCoursesView: View {
    @State private var viewModel = CCCoursesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
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
        .background(AppTheme.background).navigationTitle("小课堂")
        .task { await viewModel.loadCourses() }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer().frame(height: 80)
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textMuted)
            Text("暂无课程")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    func categorySection(title: String, icon: String, color: Color, courses: [CCXuanAPI.CourseItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack { Image(systemName: icon).foregroundColor(color); Text(title).font(.system(size: 18, weight: .semibold)) }
            ForEach(courses) { course in
                NavigationLink(value: CCAppRoute.courseDetail(course)) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.title).font(.system(size: 15, weight: .medium))
                            HStack(spacing: 8) {
                                Text(course.tag).font(.system(size: 11)).foregroundColor(AppTheme.primaryDark)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(AppTheme.info.opacity(0.3)).cornerRadius(4)
                                Text("\(course.duration / 60) 分钟").font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(AppTheme.textMuted)
                    }.padding().background(AppTheme.cardBackground).cornerRadius(AppRadius.md)
                }
            }
        }
    }
}
