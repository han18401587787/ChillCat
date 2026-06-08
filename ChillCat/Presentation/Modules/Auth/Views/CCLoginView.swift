import SwiftUI

struct CCLoginView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @State private var phone = ""
    @State private var code = ""
    @State private var sentCode = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.circle.fill").font(.system(size: 56)).foregroundColor(Color(hex: "5A7A8A"))
            Text("登录绪安").font(.system(size: 24, weight: .bold))
            Text("输入你的手机号").font(.system(size: 15)).foregroundColor(.secondary)
            VStack(spacing: 12) {
                TextField("请输入手机号确认", text: $phone)
                    .keyboardType(.phonePad).textFieldStyle(.roundedBorder)
                if sentCode {
                    TextField("验证码", text: $code)
                        .keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                }
            }.padding(.horizontal, 32)
            Button(action: { sentCode ? coordinator.isLoggedIn = true : (sentCode = true) }) {
                Text(sentCode ? "登录" : "发送验证码").fontWeight(.semibold)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color(hex: phone.count >= 11 ? "5A7A8A" : "B8D4E3"))
                    .foregroundColor(.white).cornerRadius(12)
            }.padding(.horizontal, 32).disabled(phone.count < 11)
            HStack(spacing: 4) {
                Text("使用即代表同意").font(.system(size: 12)).foregroundColor(.secondary)
                Text("《用户协议》").font(.system(size: 12)).foregroundColor(Color(hex: "5A7A8A"))
                Text("和").font(.system(size: 12)).foregroundColor(.secondary)
                Text("《隐私政策》").font(.system(size: 12)).foregroundColor(Color(hex: "5A7A8A"))
            }
            Spacer()
        }
        .background(Color(hex: "F9F6F2"))
    }
}
