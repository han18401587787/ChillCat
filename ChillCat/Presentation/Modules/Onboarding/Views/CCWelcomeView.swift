import SwiftUI

struct CCWelcomeView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8D9F0").opacity(0.6), Color(hex: "B8D4E3").opacity(0.4), Color(hex: "F9F6F2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 72)).foregroundColor(Color(hex: "5A7A8A"))
                Text("绪安").font(.system(size: 36, weight: .bold))
                Text("陪你温柔自愈").font(.system(size: 18)).foregroundColor(Color(hex: "7A9AAA"))
                VStack(spacing: 8) {
                    Text("接住所有情绪").font(.system(size: 22, weight: .medium))
                    Text("温柔自愈  自在松弛").font(.system(size: 16)).foregroundColor(.secondary)
                }.padding(.top, 32)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: { coordinator.isLoggedIn = true }) {
                        Text("匿名进入").fontWeight(.semibold).frame(maxWidth: .infinity)
                            .padding(.vertical, 16).background(Color(hex: "5A7A8A")).foregroundColor(.white).cornerRadius(12)
                    }
                    Button("已有账号登录") { coordinator.navigate(to: .login) }.foregroundColor(Color(hex: "5A7A8A"))
                }.padding(.horizontal, 32).padding(.bottom, 50)
            }
        }
    }
}
