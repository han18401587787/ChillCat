import SwiftUI
import Observation

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
        "情绪管理": ("heart.text.clipboard.fill", Color(hex: "D4C8E8")),
        "焦虑治愈": ("leaf.circle.fill", Color(hex: "D5E8D4")),
        "睡前助眠": ("moon.stars.fill", Color(hex: "B8D4E3")),
        "职场解压": ("briefcase.fill", Color(hex: "E8D9F0")),
        "成长": ("sparkles", Color(hex: "E8D9C8")),
    ]

    func loadCourses() async {
        loadState = .loading
        do {
            let all = try await CCXuanAPI.getCourses()
            if all.isEmpty {
                loadState = .empty
                categories = []
            } else {
                let grouped = Dictionary(grouping: all, by: { $0.category })
                categories = grouped.map { (name, items) in
                    let (icon, color) = icons[name] ?? ("book.fill", Color(hex: "D4C8E8"))
                    return (name, icon, color, items)
                }
                loadState = .loaded
            }
        } catch {
            loadState = .error(error.localizedDescription)
            categories = []
        }
    }
}
