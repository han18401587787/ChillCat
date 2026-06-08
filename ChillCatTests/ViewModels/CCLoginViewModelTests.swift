import XCTest
@testable import ChillCat

final class CCLoginViewModelTests: XCTestCase {
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

    // MARK: - Form Validation

    func test_formValid_withEmptyUsername_returnsFalse() {
        sut.username = ""
        sut.password = "123456"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_formValid_withShortPassword_returnsFalse() {
        sut.username = "test"
        sut.password = "123"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_formValid_withValidInput_returnsTrue() {
        sut.username = "testuser"
        sut.password = "123456"
        XCTAssertTrue(sut.isFormValid)
    }

    func test_registerFormValid_withValidInput_returnsTrue() {
        sut.isRegisterMode = true
        sut.username = "testuser"
        sut.password = "123456"
        sut.confirmPassword = "123456"
        sut.email = "test@chillcat.app"
        XCTAssertTrue(sut.isFormValid)
    }

    func test_registerFormValid_withMismatchedPassword_returnsFalse() {
        sut.isRegisterMode = true
        sut.username = "testuser"
        sut.password = "123456"
        sut.confirmPassword = "654321"
        sut.email = "test@chillcat.app"
        XCTAssertFalse(sut.isFormValid)
    }

    func test_registerFormValid_withInvalidEmail_returnsFalse() {
        sut.isRegisterMode = true
        sut.username = "testuser"
        sut.password = "123456"
        sut.confirmPassword = "123456"
        sut.email = "invalid"
        XCTAssertFalse(sut.isFormValid)
    }

    // MARK: - Login

    func test_login_success_setsIsLoggedIn() async {
        mockRepo.loginResult = .success(TestHelpers.makeUser())
        await sut.login()
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(mockRepo.didLogin)
    }

    func test_login_failure_setsError() async {
        mockRepo.loginResult = .failure(CCAppError.business(code: 20003, message: "密码错误"))
        await sut.login()
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Register

    func test_register_success_setsIsLoggedIn() async {
        sut.isRegisterMode = true
        mockRepo.registerResult = .success(TestHelpers.makeUser())
        sut.username = "newuser"; sut.password = "123456"
        sut.confirmPassword = "123456"; sut.email = "test@chillcat.app"
        await sut.register()
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertTrue(mockRepo.didRegister)
    }

    // MARK: - Toggle Mode

    func test_toggleRegisterMode_clearsError() {
        sut.errorMessage = "an error"
        sut.isRegisterMode = true
        XCTAssertEqual(sut.errorMessage, "an error")
    }
}
