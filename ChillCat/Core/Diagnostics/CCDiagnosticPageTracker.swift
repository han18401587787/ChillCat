import SwiftUI

/// 页面追踪 Modifier — 在 View 的 onAppear/onDisappear 时自动更新诊断面板的当前页面信息
struct CCDiagnosticPageTracker: ViewModifier {
    let pageName: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                #if DEBUG
                CCDiagnosticCollector.shared.currentPage = pageName
                #endif
            }
    }
}

extension View {
    /// 标记当前页面名称，供诊断面板使用
    /// - Parameter name: 页面名称，如 "CCHomeView"
    func trackPage(_ name: String) -> some View {
        #if DEBUG
        return self.modifier(CCDiagnosticPageTracker(pageName: name))
        #else
        return self
        #endif
    }
}
