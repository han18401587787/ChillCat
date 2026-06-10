import SwiftUI
import Kingfisher

struct CCCoursesView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @State private var courses: [CCXuanAPI.CourseItem] = []
    @State private var categories: [(name: String, icon: String, color: Color, items: [CCXuanAPI.CourseItem])] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                Text("小课堂").font(.system(size: 24, weight: .bold))
                if categories.isEmpty {
                    CCSkeletonList(count: 6)
                } else {
                    ForEach(categories, id: \.name) { cat in
                        categorySection(title: cat.name, icon: cat.icon, color: cat.color, courses: cat.items)
                    }
                }
            }.padding()
        }
        .background(theme.background).navigationTitle("小课堂")
        .task { await loadCourses() }
    }

    private func loadCourses() async {
        do {
            let all = try await CCXuanAPI.getCourses()
            courses = all
            let grouped = Dictionary(grouping: all, by: { $0.category })
            let icons: [String: (String, Color)] = [
                "情绪管理": ("heart.text.clipboard.fill", Color(hex: "D4C8E8")),
                "焦虑治愈": ("leaf.circle.fill", Color(hex: "D5E8D4")),
                "睡前助眠": ("moon.stars.fill", Color(hex: "B8D4E3")),
                "职场解压": ("briefcase.fill", Color(hex: "E8D9F0")),
                "成长": ("sparkles", Color(hex: "E8D9C8")),
            ]
            categories = grouped.map { (name, items) in
                let (icon, color) = icons[name] ?? ("book.fill", Color(hex: "D4C8E8"))
                return (name, icon, color, items)
            }
        } catch {}
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