import XCTest
@testable import ChillCat

final class CCProfileViewModelTests: XCTestCase {
    var mockRepo: MockUserRepository!
    var sut: CCProfileViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
        sut = CCProfileViewModel(profileUseCase: CCUserProfileUseCase(userRepository: mockRepo))
    }

    func test_displayName_whenNoUser_returnsDefault() {
        XCTAssertEqual(sut.displayName, "未登录")
    }

    func test_displayName_whenUserExists_returnsName() async {
        mockRepo.profileResult = .success(TestHelpers.makeUser(name: "小明"))
        await sut.loadProfile()
        XCTAssertEqual(sut.displayName, "小明")
    }

    func test_loadProfile_success_storesUser() async {
        mockRepo.profileResult = .success(TestHelpers.makeUser(email: "x@chillcat.app"))
        await sut.loadProfile()
        XCTAssertEqual(sut.displayEmail, "x@chillcat.app")
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadProfile_failure_setsError() async {
        mockRepo.profileResult = .failure(CCAppError.unknown)
        await sut.loadProfile()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_logout_clearsUser() async {
        mockRepo.profileResult = .success(TestHelpers.makeUser())
        await sut.loadProfile()
        XCTAssertNotNil(sut.user)
        await sut.logout()
        XCTAssertNil(sut.user)
        XCTAssertTrue(mockRepo.didLogout)
    }
}
