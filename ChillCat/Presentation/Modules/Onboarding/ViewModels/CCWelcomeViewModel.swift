import SwiftUI
import Observation
import KeychainAccess
import Combine

@MainActor
@Observable
final class CCWelcomeViewModel {
    var isLoading = false
    var errorMessage: String?

    func enterApp(coordinator: CCAppCoordinator) {
        coordinator.hasSeenWelcome = true
        let keychain = Keychain(service: "app.xuanpeace.token")

        // 已有有效 token，直接进入
        if let existingToken = keychain["access_token"], !existingToken.isEmpty {
            LogI("[Welcome] 已有 Token, 直接进入", module: .auth, category: "Welcome")
            coordinator.isLoggedIn = true
            return
        }

        isLoading = true
        errorMessage = nil
        LogD("[Welcome] 后台获取Token → \(CCAppEnvironment.current.baseURL)", module: .network, category: "Welcome")
        Task {
            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                LogI("[Welcome] Token已缓存 user=\(resp.username)", module: .auth, category: "Welcome")
                keychain["access_token"] = resp.token
                coordinator.isLoggedIn = true
            } catch {
                LogW("[Welcome] Token获取失败: \(error.localizedDescription)", module: .auth, category: "Welcome")
                // TLS 错误给出明确提示
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == -1200 {
                    errorMessage = "服务器 HTTPS 证书异常，请联系管理员"
                } else {
                    errorMessage = "连接失败，请检查网络后重试"
                }
            }
            isLoading = false
        }
    }
}
