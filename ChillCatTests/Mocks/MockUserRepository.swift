import Foundation
@testable import ChillCat

final class MockUserRepository: CCUserRepositoryProtocol {
    var loginResult: Result<CCUser, Error> = .failure(CCAppError.unknown)
    var registerResult: Result<CCUser, Error> = .failure(CCAppError.unknown)
    var profileResult: Result<CCUser, Error> = .failure(CCAppError.unknown)
    var didLogout = false
    var didLogin = false
    var didRegister = false

    func login(username: String, password: String) async throws -> CCUser {
        didLogin = true
        switch loginResult {
        case .success(let user): return user
        case .failure(let error): throw error
        }
    }

    func register(username: String, password: String, email: String) async throws -> CCUser {
        didRegister = true
        switch registerResult {
        case .success(let user): return user
        case .failure(let error): throw error
        }
    }

    func fetchProfile() async throws -> CCUser {
        switch profileResult {
        case .success(let user): return user
        case .failure(let error): throw error
        }
    }

    func updateProfile(_ user: CCUser) async throws -> CCUser { user }
    func logout() async { didLogout = true }
}
