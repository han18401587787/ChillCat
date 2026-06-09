import SwiftUI

struct CCLoginView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @State private var viewModel = CCLoginViewModel(
        loginUseCase: CCAppDependencyContainer.shared.container.resolve(),
        userRepository: CCAppDependencyContainer.shared.container.resolve()
    )

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.circle.fill").font(.system(size: 56)).foregroundColor(Color(hex: "5A7A8A"))
            Text(viewModel.isRegisterMode ? "注册绪安" : "登录绪安").font(.system(size: 24, weight: .bold))
            Text(viewModel.isRegisterMode ? "创建你的绪安账户" : "输入你的用户名和密码").font(.system(size: 15)).foregroundColor(.secondary)

            VStack(spacing: 12) {
                TextField("用户名", text: $viewModel.username)
                    .textContentType(.username).textFieldStyle(.roundedBorder)
                    .autocapitalization(.none).disableAutocorrection(true)

                SecureField("密码", text: $viewModel.password)
                    .textContentType(.password).textFieldStyle(.roundedBorder)

                if viewModel.isRegisterMode {
                    SecureField("确认密码", text: $viewModel.confirmPassword)
                        .textContentType(.password).textFieldStyle(.roundedBorder)
                    TextField("邮箱", text: $viewModel.email)
                        .keyboardType(.emailAddress).textContentType(.emailAddress).textFieldStyle(.roundedBorder)
                        .autocapitalization(.none).disableAutocorrection(true)
                }

                if let error = viewModel.errorMessage {
                    Text(error).font(.system(size: 13)).foregroundColor(.red)
                }
            }.padding(.horizontal, 32)

            Button(action: { Task { await viewModel.submit() } }) {
                Text(viewModel.isLoading ? "请稍候..." : (viewModel.isRegisterMode ? "注册" : "登录"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color(hex: viewModel.isFormValid ? "5A7A8A" : "B8D4E3"))
                    .foregroundColor(.white).cornerRadius(12)
            }.padding(.horizontal, 32).disabled(!viewModel.isFormValid || viewModel.isLoading)

            Button(action: {
                viewModel.isRegisterMode.toggle()
                viewModel.errorMessage = nil
            }) {
                Text(viewModel.isRegisterMode ? "已有账号？去登录" : "没有账号？去注册")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "5A7A8A"))
            }

            HStack(spacing: 4) {
                Text("使用即代表同意").font(.system(size: 12)).foregroundColor(.secondary)
                Text("《用户协议》").font(.system(size: 12)).foregroundColor(Color(hex: "5A7A8A"))
                Text("和").font(.system(size: 12)).foregroundColor(.secondary)
                Text("《隐私政策》").font(.system(size: 12)).foregroundColor(Color(hex: "5A7A8A"))
            }
            Spacer()
        }
        .background(Color(hex: "F9F6F2"))
        .onChange(of: viewModel.isLoggedIn) { _, newValue in
            if newValue { coordinator.isLoggedIn = true }
        }
    }
}
