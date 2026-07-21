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

    /// 提交结果 — 区分成功 / 入队 / 配置错误
    enum CCBugSubmissionResult {
        case success(issueURL: String)
        case queued                       // 最终失败，已存本地队列等待补传
        case failed(Error)               // 配置类错误（token 缺失/无效），无法重试
    }

    /// 提交 Bug 报告到 GitHub Issue（带指数退避重试 + 失败落队）
    /// - Parameters:
    ///   - title: Issue 标题
    ///   - body: Issue 正文（Markdown 格式）
    ///   - screenshot: 可选的截图 Data
    ///   - labels: 标签，默认 ["bug", "from-debug-panel"]
    /// - Returns: 提交结果
    func submitWithQueue(
        title: String,
        body: String,
        screenshot: Data? = nil,
        labels: [String] = ["bug", "from-debug-panel"]
    ) async -> CCBugSubmissionResult {
        // Token 缺失/无效属于配置错误，重试无意义，直接报错
        guard let token = getToken() else {
            return .failed(CCGitHubError.missingToken)
        }

        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                let issueURL = try await createIssue(title: title, body: body, labels: labels, token: token)
                if let screenshot = screenshot, let issueNumber = extractIssueNumber(from: issueURL) {
                    let imageURL = try await uploadImage(screenshot, token: token)
                    try? await addComment(issueNumber: issueNumber, body: "![截图](\(imageURL))", token: token)
                }
                return .success(issueURL: issueURL)
            } catch {
                lastError = error
                if attempt < maxRetries {
                    // 指数退避：1s → 2s → 4s
                    let delay = UInt64(pow(2.0, Double(attempt - 1))) * 1_000_000_000
                    LogW("Bug 提交失败 (attempt \(attempt)/\(maxRetries))，\(Double(delay) / 1e9)s 后重试: \(error.localizedDescription)", module: .network, category: "GitHub")
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }

        // 最终失败 — 判断是否可以入队（仅网络/服务端错误入队，配置错误不入队）
        if shouldQueue(lastError) {
            CCBugSubmissionQueue.shared.enqueue(title: title, body: body, screenshot: screenshot, labels: labels)
            LogW("Bug 提交最终失败，已存入本地队列等待补传: \(title)", module: .network, category: "GitHub")
            return .queued
        } else {
            return .failed(lastError ?? CCGitHubError.networkFailure)
        }
    }

    /// 判断错误是否可入队重试（网络/服务端临时错误可重试；token 配置错误不可重试）
    private func shouldQueue(_ error: Error?) -> Bool {
        guard let error = error as? CCGitHubError else { return true }
        switch error {
        case .missingToken, .invalidToken:
            return false
        case .networkFailure, .apiError, .parseError:
            return true
        }
    }

    /// 冷启补传 — 静默重试本地队列中所有待提交项
    /// 在网络可用时自动补传，用户无感
    func processPendingQueue() async {
        let pending = CCBugSubmissionQueue.shared.pendingItems()
        guard !pending.isEmpty else { return }

        LogI("冷启检测到 \(pending.count) 条未提交 Bug 草稿，开始自动补传", module: .ui, category: "BugReport")

        guard let token = getToken() else {
            LogW("本地有 \(pending.count) 条未提交 Bug，但 GitHub Token 未配置，跳过补传（联网配置后下次启动自动补传）", module: .ui, category: "BugReport")
            return
        }

        for item in pending {
            do {
                let issueURL = try await createIssue(title: item.title, body: item.body, labels: item.labels, token: token)
                if let base64 = item.screenshotBase64,
                   let data = Data(base64Encoded: base64),
                   let issueNumber = extractIssueNumber(from: issueURL) {
                    let imageURL = try await uploadImage(data, token: token)
                    try? await addComment(issueNumber: issueNumber, body: "![截图](\(imageURL))", token: token)
                }
                CCBugSubmissionQueue.shared.remove(item.id)
                LogI("未提交 Bug 补传成功: \(item.title) → \(issueURL)", module: .ui, category: "BugReport")
            } catch {
                CCBugSubmissionQueue.shared.incrementRetry(item.id, error: error.localizedDescription)
                LogW("未提交 Bug 补传失败（剩余 \(CCBugSubmissionQueue.shared.count()) 条待处理）: \(error.localizedDescription)", module: .ui, category: "BugReport")
            }
        }
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
