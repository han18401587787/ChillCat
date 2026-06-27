import SwiftUI

struct CCWelcomeView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCWelcomeViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.warmPurple.opacity(0.3).opacity(0.6), AppTheme.info.opacity(0.4), AppTheme.background],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "leaf.circle.fill").font(.system(size: 72)).foregroundColor(AppTheme.primaryDark)
                Text("绪安").font(.system(size: 36, weight: .bold))
                Text("陪你温柔自愈").font(.system(size: 18)).foregroundColor(AppTheme.info)
                VStack(spacing: 8) {
                    Text("接住所有情绪").font(.system(size: 22, weight: .medium))
                    Text("温柔自愈  自在松弛").font(.system(size: 16)).foregroundColor(.secondary)
                }.padding(.top, 32)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: { viewModel.enterApp(coordinator: coordinator) }) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("匿名进入").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.primaryDark).foregroundColor(.white).cornerRadius(12)
                    .disabled(viewModel.isLoading)

                    Button("已有账号登录") {
                        coordinator.hasSeenWelcome = true
                    }
                    .foregroundColor(AppTheme.primaryDark)
                    .disabled(viewModel.isLoading)
                }.padding(.horizontal, 32).padding(.bottom, 50)
            }
        }
        .alert("提示", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("重试") { viewModel.enterApp(coordinator: coordinator) }
            Button("取消", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
