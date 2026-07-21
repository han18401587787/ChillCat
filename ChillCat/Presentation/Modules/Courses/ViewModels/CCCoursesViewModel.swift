import SwiftUI
import Observation
import Combine

enum CCCoursesLoadState: Equatable {
    case loading
    case loaded
    case empty
    case error(String)

    static func == (lhs: CCCoursesLoadState, rhs: CCCoursesLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.loaded, .loaded), (.empty, .empty): return true
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }
}

@MainActor
@Observable
final class CCCoursesViewModel {
    var loadState: CCCoursesLoadState = .loading
    var categories: [(name: String, icon: String, color: Color, items: [CCXuanAPI.CourseItem])] = []

    private let icons: [String: (String, Color)] = [
        "情绪管理": ("heart.text.clipboard.fill", Color(hex: "A085C6")),
        "焦虑治愈": ("leaf.circle.fill", Color.xuanMint.opacity(0.3)),
        "睡前助眠": ("moon.stars.fill", Color.xuanInfo),
        "职场解压": ("briefcase.fill", Color(hex: "A085C6").opacity(0.3)),
        "成长": ("sparkles", Color.xuanApricotLight),
    ]

    func loadCourses() async {
        LogD("[Courses] loadCourses start", module: .network, category: "Courses")
        loadState = .loading
        do {
            let all = try await CCXuanAPI.getCourses()
            if all.isEmpty {
                loadState = .empty
                categories = []
                LogI("[Courses] loadCourses done: empty", module: .network, category: "Courses")
            } else {
                let grouped = Dictionary(grouping: all, by: { $0.category ?? "其他" })
                categories = grouped.map { (name, items) in
                    let (icon, color) = icons[name] ?? ("book.fill", Color(hex: "A085C6"))
                    return (name, icon, color, items)
                }
                loadState = .loaded
                LogI("[Courses] loadCourses done: \(all.count) courses, \(categories.count) categories", module: .network, category: "Courses")
            }
        } catch {
            loadState = .error(error.localizedDescription)
            categories = []
            LogE("[Courses] loadCourses failed: \(error)", module: .network, category: "Courses")
        }
    }
}
