import Foundation
@testable import ChillCat

final class MockMemberRepository: CCMemberRepositoryProtocol {
    var memberInfoResult: Result<CCMemberInfo, Error> = .failure(CCAppError.unknown)
    var purchaseResult: Result<CCMemberInfo, Error> = .failure(CCAppError.unknown)
    var didPurchase = false

    func fetchMemberInfo() async throws -> CCMemberInfo {
        switch memberInfoResult {
        case .success(let info): return info
        case .failure(let e): throw e
        }
    }

    func purchase(product: CCMemberProduct) async throws -> CCMemberInfo {
        didPurchase = true
        switch purchaseResult {
        case .success(let info): return info
        case .failure(let e): throw e
        }
    }
}
