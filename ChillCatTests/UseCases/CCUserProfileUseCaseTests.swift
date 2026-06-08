import XCTest
@testable import ChillCat

final class CCUserProfileUseCaseTests: XCTestCase {
    var mockRepo: MockUserRepository!
    var sut: CCUserProfileUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
        sut = CCUserProfileUseCase(userRepository: mockRepo)
    }

    func test_fetchProfile_success_returnsUser() async throws {
        mockRepo.profileResult = .success(TestHelpers.makeUser(name: "小明"))
        let user = try await sut.fetchProfile()
        XCTAssertEqual(user.name, "小明")
    }

    func test_fetchProfile_failure_throws() async {
        mockRepo.profileResult = .failure(CCAppError.unknown)
        do {
            _ = try await sut.fetchProfile()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_logout_callsRepositoryLogout() async {
        await sut.logout()
        XCTAssertTrue(mockRepo.didLogout)
    }
}
