import Foundation
import SwiftUI

#if DEBUG

// MARK: - Debug Action Registry

/// 全局 Debug Action 注册表 — 各页面通过 `.debugAction("id")` 注册可远程调用的操作
/// AppDebugServer 通过 `/list_actions` 暴露注册表，通过 `/activate` 触发操作
///
/// 用法（在任意 View 中）：
/// ```swift
/// Button("刷新") { ... }
///     .debugAction("home.refresh")
/// ```
@MainActor
final class CCDebugActionRegistry: ObservableObject {
    static let shared = CCDebugActionRegistry()

    /// 已注册的 Debug Action
    @Published private(set) var actions: [CCDebugAction] = []

    private init() {}

    // MARK: - 注册 / 注销

    func register(_ action: CCDebugAction) {
        guard !actions.contains(where: { $0.id == action.id }) else {
            LogW("Debug Action 重复注册: \(action.id)", module: .debug, category: "Registry")
            return
        }
        actions.append(action)
        LogD("Debug Action 已注册: \(action.id) @ \(action.pageName)", module: .debug, category: "Registry")
    }

    func unregister(id: String) {
        actions.removeAll { $0.id == id }
    }

    /// 按页面名筛选
    func actions(for page: String) -> [CCDebugAction] {
        actions.filter { $0.pageName == page }
    }

    /// 查找指定 action
    func find(id: String) -> CCDebugAction? {
        actions.first { $0.id == id }
    }

    /// 激活一个 action（由 AppDebugServer 的 /activate 路由调用）
    func activate(id: String) -> Bool {
        guard let action = find(id) else {
            LogW("Debug Action 未找到: \(id)", module: .debug, category: "Registry")
            return false
        }
        LogI("Debug Action 激活: \(id) @ \(action.pageName)", module: .debug, category: "Registry")
        action.handler()
        return true
    }

    // MARK: - 导出（供 /list_actions）

    func exportJSON() -> String {
        let list = actions.map { action in
            [
                "id": action.id,
                "page": action.pageName,
                "label": action.label,
                "description": action.description,
            ]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: list, options: .prettyPrinted),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }
}

// MARK: - Debug Action 模型

struct CCDebugAction: Identifiable, Sendable {
    let id: String
    let pageName: String
    let label: String
    let description: String
    let handler: @MainActor () -> Void

    // 为 Sendable 提供非隔离比较
    var nonisolatedID: String { id }
    var nonisolatedPageName: String { pageName }
    var nonisolatedLabel: String { label }
    var nonisolatedDescription: String { description }
}

// MARK: - SwiftUI Modifier

struct DebugActionModifier: ViewModifier {
    let actionID: String
    let pageName: String
    let label: String
    let description: String
    let handler: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                CCDebugActionRegistry.shared.register(
                    CCDebugAction(
                        id: actionID,
                        pageName: pageName,
                        label: label,
                        description: description,
                        handler: handler
                    )
                )
            }
            .onDisappear {
                CCDebugActionRegistry.shared.unregister(id: actionID)
            }
    }
}

extension View {
    /// 注册一个 Debug Action，供 AppDebugServer 远程调用
    ///
    /// - Parameters:
    ///   - id: 唯一标识符，建议格式 `页面.操作`，如 `home.refresh`
    ///   - pageName: 所属页面名
    ///   - label: 人类可读标签
    ///   - description: 操作描述
    ///   - handler: 点击时执行的回调
    func debugAction(
        id: String,
        pageName: String,
        label: String,
        description: String = "",
        handler: @escaping () -> Void
    ) -> some View {
        #if DEBUG
        return self.modifier(
            DebugActionModifier(
                actionID: id,
                pageName: pageName,
                label: label,
                description: description,
                handler: handler
            )
        )
        #else
        return self
        #endif
    }
}

// MARK: - 辅助扩展

extension CCLogModule {
    static let debug = CCLogModule(rawValue: "Debug")
}

#endif // DEBUG
