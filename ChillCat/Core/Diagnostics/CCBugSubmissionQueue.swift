import Foundation

/// 本地 Bug 提交队列 — 提交失败后将草稿持久化到磁盘
/// 冷启或网络恢复后由 CCGitHubIssueReporter 自动补传
/// 仅在 #if DEBUG 下编译
#if DEBUG

/// 队列中的单条 Bug 草稿
struct CCBugSubmissionItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let body: String
    let screenshotBase64: String?
    let labels: [String]
    let createdAt: Date
    var retryCount: Int
    var lastError: String?
}

/// 本地提交队列 — JSON 持久化到 Application Support 目录
@MainActor
final class CCBugSubmissionQueue {
    static let shared = CCBugSubmissionQueue()

    /// 单条草稿最大补传次数（超过后放弃，需用户手动处理）
    static let maxRetries = 5

    private let fileURL: URL
    private var items: [CCBugSubmissionItem] = []
    private let lock = NSLock()

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        fileURL = dir.appendingPathComponent("cc_bug_submission_queue.json")
        load()
    }

    // MARK: - 入队

    func enqueue(title: String, body: String, screenshot: Data?, labels: [String]) {
        let item = CCBugSubmissionItem(
            id: UUID(),
            title: title,
            body: body,
            screenshotBase64: screenshot?.base64EncodedString(),
            labels: labels,
            createdAt: Date(),
            retryCount: 0,
            lastError: nil
        )
        lock.lock()
        items.append(item)
        lock.unlock()
        save()
        LogW("Bug 草稿已存入本地队列（共 \(items.count) 条待提交）", module: .ui, category: "BugReport")
    }

    // MARK: - 查询

    /// 仍可补传的草稿（未超过最大重试次数）
    func pendingItems() -> [CCBugSubmissionItem] {
        lock.lock()
        let pending = items.filter { $0.retryCount < Self.maxRetries }
        lock.unlock()
        return pending
    }

    func count() -> Int {
        lock.lock()
        let c = items.count
        lock.unlock()
        return c
    }

    // MARK: - 更新

    func remove(_ id: UUID) {
        lock.lock()
        items.removeAll { $0.id == id }
        lock.unlock()
        save()
    }

    func incrementRetry(_ id: UUID, error: String) {
        lock.lock()
        if let idx = items.firstIndex(where: { $0.id == id }) {
            var item = items[idx]
            item.retryCount += 1
            item.lastError = error
            items[idx] = item
        }
        lock.unlock()
        save()
    }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CCBugSubmissionItem].self, from: data) else {
            return
        }
        lock.lock()
        items = decoded
        lock.unlock()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }
}

#endif
