import SwiftUI
import Observation
import KeychainAccess

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
            print("✅ [Welcome] 已有 Token, 直接进入")
            coordinator.isLoggedIn = true
            return
        }

        isLoading = true
        errorMessage = nil
        print("🌐 [Welcome] 后台获取Token → \(CCAppEnvironment.current.baseURL)")
        Task {
            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                print("✅ [Welcome] Token已缓存 user=\(resp.username)")
                keychain["access_token"] = resp.token
                coordinator.isLoggedIn = true
            } catch {
                print("⚠️ [Welcome] Token获取失败: \(error.localizedDescription)")
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
