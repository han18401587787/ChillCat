import SwiftUI
import Observation
import KeychainAccess

@MainActor
@Observable
final class CCWelcomeViewModel {
    var isLoading = false
    var errorMessage: String?

    func enterApp(coordinator: CCAppCoordinator) {
        isLoading = true
        errorMessage = nil
        coordinator.hasSeenWelcome = true

        print("🌐 [绪安] 后台获取Token → \(CCAppEnvironment.current.baseURL)")
        Task {
            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                print("✅ [绪安] Token已缓存 user=\(resp.username)")
                Keychain(service: "app.xuanpeace.token")["access_token"] = resp.token
                coordinator.isLoggedIn = true
            } catch {
                print("⚠️ [绪安] Token获取失败: \(error.localizedDescription)")
                errorMessage = "连接失败，请检查网络后重试"
            }
            isLoading = false
        }
    }
}
