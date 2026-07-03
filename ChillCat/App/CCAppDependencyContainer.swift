import Foundation

final class CCAppDependencyContainer {
    static let shared = CCAppDependencyContainer()
    let container: CCDIContainer

    private init() {
        container = CCDIContainer()
        registerDependencies()
    }

    private func registerDependencies() {
        registerCoreServices()
        registerRepositories()
        registerUseCases()
    }

    private func registerCoreServices() {
        container.registerSingleton(CCKeychainManagerProtocol.self) { _ in CCKeychainManager() }
        container.registerSingleton(CCUserDefaultsManagerProtocol.self) { _ in CCUserDefaultsManager() }
        container.registerSingleton(CCCacheManagerProtocol.self) { _ in CCCacheManager(cacheName: "chillcat_cache") }
        container.registerSingleton(CCReachabilityManager.self) { _ in CCReachabilityManager.shared }
    }

    private func registerRepositories() {
        container.register(CCUserRepositoryProtocol.self) { r in
            CCUserRepository(remoteDataSource: CCUserRemoteDataSource(), localDataSource: CCUserLocalDataSource(keychainManager: r.resolve()))
        }
        container.register(CCMemberRepositoryProtocol.self) { r in
            CCMemberRepository(remoteDataSource: CCMemberRemoteDataSource(), localDataSource: CCMemberLocalDataSource())
        }
    }

    private func registerUseCases() {
        container.register(CCLoginUseCase.self) { r in CCLoginUseCase(userRepository: r.resolve()) }
        container.register(CCUserProfileUseCase.self) { r in CCUserProfileUseCase(userRepository: r.resolve()) }
        container.register(CCFetchMemberInfoUseCase.self) { r in CCFetchMemberInfoUseCase(repository: r.resolve()) }
        container.register(CCPurchaseMemberUseCase.self) { r in CCPurchaseMemberUseCase(repository: r.resolve()) }
    }
}
