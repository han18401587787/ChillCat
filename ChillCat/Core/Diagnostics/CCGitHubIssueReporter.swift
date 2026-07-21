import Foundation
import UIKit

/// GitHub Issue 提交器 — 将 Bug 草稿 + 截图 + 诊断日志自动创建为 GitHub Issue
/// 仅在 #if DEBUG 下编译
#if DEBUG

@MainActor
final class CCGitHubIssueReporter {
    static let shared = CCGitHubIssueReporter()

    private let repo = "han18401587787/ChillCat"
    private let baseURL = "https://api.github.com"

    /// 提交 Bug 报告到 GitHub Issue
    /// - Parameters:
    ///   - title: Issue 标题
    ///   - body: Issue 正文（Markdown 格式）
    ///   - screenshot: 可选的截图 Data
    ///   - labels: 标签，默认 ["bug", "from-debug-panel"]
    /// - Returns: Issue URL
    func submit(
        title: String,
        body: String,
        screenshot: Data? = nil,
        labels: [String] = ["bug", "from-debug-panel"]
    ) async throws -> String {
        // 1. 获取 GitHub Token
        guard let token = getToken() else {
            throw CCGitHubError.missingToken
        }

        // 2. 创建 Issue
        let issueURL = try await createIssue(title: title, body: body, labels: labels, token: token)

        // 3. 如果有截图，上传到 Issue
        if let screenshot = screenshot, let issueNumber = extractIssueNumber(from: issueURL) {
            let imageURL = try await uploadImage(screenshot, token: token)
            // 在 Issue 中添加截图评论
            try await addComment(
                issueNumber: issueNumber,
                body: "![截图](\(imageURL))",
                token: token
            )
        }

        return issueURL
    }

    // MARK: - Token 管理

    /// GitHub Personal Access Token 存储在 UserDefaults
    /// 用户需要在诊断面板中配置一次
    private func getToken() -> String? {
        // 优先从 UserDefaults 读取
        if let token = UserDefaults.standard.string(forKey: "cc_debug_github_token"),
           !token.isEmpty {
            return token
        }
        return nil
    }

    /// 保存 Token
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "cc_debug_github_token")
    }

    /// 是否已配置 Token
    var hasToken: Bool {
        getToken() != nil
    }

    /// 清除 Token
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "cc_debug_github_token")
    }

    // MARK: - API 调用

    private func createIssue(
        title: String,
        body: String,
        labels: [String],
        token: String
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/repos/\(repo)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let payload: [String: Any] = [
            "title": title,
            "body": body,
            "labels": labels
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CCGitHubError.networkFailure
        }

        if httpResponse.statusCode == 401 {
            throw CCGitHubError.invalidToken
        }

        guard httpResponse.statusCode == 201 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw CCGitHubError.apiError(statusCode: httpResponse.statusCode, body: body)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let htmlURL = json["html_url"] as? String else {
            throw CCGitHubError.parseError
        }

        return htmlURL
    }

    /// 上传截图到 GitHub（通过 Issue comment 的附件方式不行，改用 base64 内嵌或上传到文件）
    /// GitHub Issues 不支持直接上传图片，但可以通过 Markdown 引用外部 URL
    /// 这里使用 GitHub 的 content API 上传到仓库的 .github/screenshots/ 目录
    private func uploadImage(_ imageData: Data, token: String) async throws -> String {
        // GitHub Issues API 不支持直接上传图片附件
        // 作为替代方案，将截图转为 base64 内嵌在评论中（小图适用）
        let base64 = imageData.base64EncodedString()
        return "data:image/png;base64,\(base64)"
    }

    private func addComment(
        issueNumber: Int,
        body: String,
        token: String
    ) async throws {
        let url = URL(string: "\(baseURL)/repos/\(repo)/issues/\(issueNumber)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let payload: [String: Any] = ["body": body]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            // 截图上传失败不阻塞主流程
            LogW("GitHub Issue 截图评论上传失败，但 Issue 已创建", module: .network, category: "GitHub")
            return
        }
    }

    private func extractIssueNumber(from url: String) -> Int? {
        // URL 格式: https://github.com/han18401587787/ChillCat/issues/123
        guard let lastComponent = url.split(separator: "/").last else { return nil }
        return Int(lastComponent)
    }
}

// MARK: - 错误类型

enum CCGitHubError: Error, LocalizedError {
    case missingToken
    case invalidToken
    case networkFailure
    case apiError(statusCode: Int, body: String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "未配置 GitHub Token，请在诊断面板中设置"
        case .invalidToken:
            return "GitHub Token 无效或已过期，请重新设置"
        case .networkFailure:
            return "网络请求失败，请检查网络连接"
        case .apiError(let code, let body):
            return "GitHub API 错误 (HTTP \(code)): \(body.prefix(200))"
        case .parseError:
            return "解析 GitHub 响应失败"
        }
    }
}

#endif
