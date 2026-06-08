import XCTest
@testable import ChillCat

final class CCMemberViewModelTests: XCTestCase {
    var mockRepo: MockMemberRepository!
    var sut: CCMemberViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockMemberRepository()
        sut = CCMemberViewModel(
            fetchMemberInfoUseCase: CCFetchMemberInfoUseCase(repository: mockRepo),
            purchaseMemberUseCase: CCPurchaseMemberUseCase(repository: mockRepo)
        )
    }

    func test_isMember_whenValid_returnsTrue() async {
        mockRepo.memberInfoResult = .success(TestHelpers.makeMemberInfo(isValid: true))
        await sut.loadData()
        XCTAssertTrue(sut.isMember)
    }

    func test_isMember_whenNonMember_returnsFalse() async {
        mockRepo.memberInfoResult = .success(TestHelpers.makeMemberInfo(isValid: false))
        await sut.loadData()
        XCTAssertFalse(sut.isMember)
    }

    func test_loadData_loadsProductsAndPrivileges() async {
        mockRepo.memberInfoResult = .success(TestHelpers.makeMemberInfo())
        await sut.loadData()
        XCTAssertEqual(sut.products.count, 4)
        XCTAssertEqual(sut.privileges.count, 6)
    }

    func test_purchase_success_updatesMemberInfo() async {
        mockRepo.purchaseResult = .success(TestHelpers.makeMemberInfo(type: .yearly))
        await sut.purchase(product: TestHelpers.makeProduct())
        XCTAssertTrue(sut.isMember)
        XCTAssertTrue(mockRepo.didPurchase)
    }
}
