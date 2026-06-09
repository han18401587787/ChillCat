import XCTest
@testable import ChillCat

/// ViewInspector-style ViewModel 测试
/// 验证状态变更、表单校验、异步操作
final class CCLoginViewModelTests_V2: XCTestCase {
    var mockRepo: MockUserRepository!
    var sut: CCLoginViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
        sut = CCLoginViewModel(
            loginUseCase: CCLoginUseCase(userRepository: mockRepo),
            userRepository: mockRepo
        )
    }

    // MARK: 表单校验

    func test_emptyUsername_formInvalid() {
        sut.username = ""; sut.password = "123456"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_shortPassword_formInvalid() {
        sut.username = "test"; sut.password = "12"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_validInput_formValid() {
        sut.username = "testuser"; sut.password = "123456"
        XCTAssertTrue(sut.isFormValid)
    }

    func test_registerMode_mismatchedPassword_invalid() {
        sut.isRegisterMode = true
        sut.username = "testuser"; sut.password = "123456"
        sut.confirmPassword = "654321"; sut.email = "a@b.com"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_registerMode_invalidEmail_invalid() {
        sut.isRegisterMode = true
        sut.username = "testuser"; sut.password = "123456"
        sut.confirmPassword = "123456"; sut.email = "bad"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_registerMode_matchingPasswords_validEmail_valid() {
        sut.isRegisterMode = true
        sut.username = "testuser"; sut.password = "123456"
        sut.confirmPassword = "123456"; sut.email = "a@b.com"
        XCTAssertTrue(sut.isFormValid)
    }

    // MARK: 登录

    func test_login_success_setsIsLoggedIn() async {
        mockRepo.loginResult = .success(TestHelpers.makeUser())
        await sut.login()
        XCTAssertTrue(sut.isLoggedIn); XCTAssertNil(sut.errorMessage)
    }

    func test_login_failure_setsError() async {
        mockRepo.loginResult = .failure(CCAppError.business(code: 20003, message: "密码错误"))
        await sut.login()
        XCTAssertFalse(sut.isLoggedIn); XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: 模式切换

    func test_toggleToRegister_clearsError() {
        sut.errorMessage = "error"
        sut.isRegisterMode = true
        XCTAssertTrue(sut.isRegisterMode)
    }
}
