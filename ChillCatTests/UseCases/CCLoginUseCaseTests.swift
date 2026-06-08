import XCTest
@testable import ChillCat

final class CCLoginUseCaseTests: XCTestCase {
    var mockRepo: MockUserRepository!
    var sut: CCLoginUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
    }

    func test_execute_withEmptyUsername_throwsValidation() async {
        sut = CCLoginUseCase(userRepository: mockRepo)
        do {
            _ = try await sut.execute(username: "   ", password: "123456")
            XCTFail("Expected error")
        } catch let error as CCAppError {
            XCTAssertEqual(error, .validation(.emptyUsername))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_execute_withEmptyPassword_throwsValidation() async {
        sut = CCLoginUseCase(userRepository: mockRepo)
        do {
            _ = try await sut.execute(username: "test", password: "")
            XCTFail("Expected error")
        } catch let error as CCAppError {
            XCTAssertEqual(error, .validation(.emptyPassword))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_execute_withValidCredentials_returnsUser() async throws {
        sut = CCLoginUseCase(userRepository: mockRepo)
        mockRepo.loginResult = .success(TestHelpers.makeUser())
        let user = try await sut.execute(username: "test", password: "123456")
        XCTAssertEqual(user.name, "测试")
    }

    func test_execute_withWrongPassword_propagatesError() async {
        sut = CCLoginUseCase(userRepository: mockRepo)
        mockRepo.loginResult = .failure(CCAppError.business(code: 20003, message: "密码错误"))
        do {
            _ = try await sut.execute(username: "test", password: "wrong")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(true)
        }
    }
}
