import SwiftUI
import KeychainAccess

struct CCWelcomeView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @State private var isLoggingIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8D9F0").opacity(0.6), Color(hex: "B8D4E3").opacity(0.4), Color(hex: "F9F6F2")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "leaf.circle.fill").font(.system(size: 72)).foregroundColor(Color(hex: "5A7A8A"))
                Text("绪安").font(.system(size: 36, weight: .bold))
                Text("陪你温柔自愈").font(.system(size: 18)).foregroundColor(Color(hex: "7A9AAA"))
                VStack(spacing: 8) {
                    Text("接住所有情绪").font(.system(size: 22, weight: .medium))
                    Text("温柔自愈  自在松弛").font(.system(size: 16)).foregroundColor(.secondary)
                }.padding(.top, 32)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: { anonymousLogin() }) {
                        if isLoggingIn {
                            ProgressView().tint(.white)
                        } else {
                            Text("匿名进入").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color(hex: "5A7A8A")).foregroundColor(.white).cornerRadius(12)
                    .disabled(isLoggingIn)

                    Button("已有账号登录") { coordinator.hasSeenWelcome = true; coordinator.navigate(to: .login) }
                        .foregroundColor(Color(hex: "5A7A8A")).disabled(isLoggingIn)
                }.padding(.horizontal, 32).padding(.bottom, 50)
            }
        }
    }

    private func anonymousLogin() {
        isLoggingIn = true
        print("🌐 [绪安] 开始匿名登录 → \(CCAppEnvironment.current.baseURL)")
        Task {
            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                print("✅ [绪安] 登录成功 user=\(resp.username)")
                let keychain = Keychain(service: "app.xuanpeace.token")
                keychain["access_token"] = resp.token
                await MainActor.run {
                    isLoggingIn = false
                    coordinator.hasSeenWelcome = true
                    coordinator.isLoggedIn = true
                }
            } catch {
                print("⚠️ [绪安] API不可用(\(error.localizedDescription))，离线进入")
                await MainActor.run {
                    isLoggingIn = false
                    coordinator.hasSeenWelcome = true
                    coordinator.isLoggedIn = true
                }
            }
        }
    }
}
