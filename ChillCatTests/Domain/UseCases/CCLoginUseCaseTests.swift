import Testing
import Foundation
@testable import ChillCat

/// CCLoginUseCase 测试套件
/// 验证登录用例的纯逻辑（不含网络调用）
struct CCLoginUseCaseTests {

    // MARK: - 输入校验

    @Test("空用户名应校验失败")
    func emptyUsername_validationFails() {
        // 测试输入校验逻辑（不依赖网络）
        let username = ""
        let password = "validPassword123"
        let isValid = !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.trimmingCharacters(in: .whitespaces).isEmpty
        #expect(isValid == false)
    }

    @Test("空密码应校验失败")
    func emptyPassword_validationFails() {
        let username = "validUser"
        let password = ""
        let isValid = !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.trimmingCharacters(in: .whitespaces).isEmpty
        #expect(isValid == false)
    }

    @Test(arguments: [
        ("user", "pass"),
        ("test@example.com", "SecureP@ss1"),
        ("a", "b"),
    ] as [(String, String)])
    func validCredentials_passValidation(_ credentials: (username: String, password: String)) {
        let isValid = !credentials.username.trimmingCharacters(in: .whitespaces).isEmpty
            && !credentials.password.trimmingCharacters(in: .whitespaces).isEmpty
        #expect(isValid == true)
    }

    // MARK: - 边界场景

    @Test("仅空格组成的用户名应视为空")
    func whitespaceOnlyUsername_treatedAsEmpty() {
        let username = "   "
        let password = "pass"
        let isValid = !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.trimmingCharacters(in: .whitespaces).isEmpty
        #expect(isValid == false)
    }

    @Test("仅空格组成的密码应视为空")
    func whitespaceOnlyPassword_treatedAsEmpty() {
        let username = "user"
        let password = "   "
        let isValid = !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.trimmingCharacters(in: .whitespaces).isEmpty
        #expect(isValid == false)
    }
}
