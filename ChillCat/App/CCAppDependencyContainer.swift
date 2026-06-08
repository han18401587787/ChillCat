//
//  CCAppDependencyContainer.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

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

    // MARK: - Core Services

    private func registerCoreServices() {
        container.registerSingleton(CCKeychainManagerProtocol.self) { _ in
            CCKeychainManager()
        }

        container.registerSingleton(CCTokenProviderProtocol.self) { resolver in
            CCTokenProvider(keychain: resolver.resolve())
        }

        container.registerSingleton(CCUserDefaultsManagerProtocol.self) { _ in
            CCUserDefaultsManager()
        }

        container.registerSingleton(CCCacheManagerProtocol.self) { _ in
            CCCacheManager(cacheName: "chillcat_cache")
        }

        container.registerSingleton(CCAPIClientProtocol.self) { resolver in
            let env = CCAppEnvironment.current
            let session = CCAPIClient.makeSession(pinnedHashes: env.pinnedCertHashes)
            return CCAPIClient(
                session: session,
                interceptor: CCTokenInterceptor(
                    tokenProvider: resolver.resolve()
                ),
                logger: CCNetworkLogger()
            )
        }

        // 网络状态监听（单例，全局共享）
        container.registerSingleton(CCReachabilityManager.self) { _ in
            CCReachabilityManager.shared
        }
    }

    // MARK: - Repositories

    private func registerRepositories() {
        container.register(CCUserRepositoryProtocol.self) { resolver in
            CCUserRepository(
                remoteDataSource: CCUserRemoteDataSource(
                    apiClient: resolver.resolve()
                ),
                localDataSource: CCUserLocalDataSource(
                    keychainManager: resolver.resolve()
                )
            )
        }

        container.register(CCMemberRepositoryProtocol.self) { resolver in
            CCMemberRepository(
                remoteDataSource: CCMemberRemoteDataSource(
                    apiClient: resolver.resolve()
                ),
                localDataSource: CCMemberLocalDataSource()
            )
        }

        container.register(CCFeedRepositoryProtocol.self) { resolver in
            CCFeedRepository(
                remoteDataSource: CCFeedRemoteDataSource(
                    apiClient: resolver.resolve()
                )
            )
        }

        container.register(CCMessageRepositoryProtocol.self) { resolver in
            CCMessageRepository(
                remote: CCMessageRemoteDataSource(
                    apiClient: resolver.resolve()
                )
            )
        }
    }

    // MARK: - UseCases

    private func registerUseCases() {
        container.register(CCLoginUseCase.self) { resolver in
            CCLoginUseCase(userRepository: resolver.resolve())
        }

        container.register(CCUserProfileUseCase.self) { resolver in
            CCUserProfileUseCase(userRepository: resolver.resolve())
        }

        container.register(CCFetchMemberInfoUseCase.self) { resolver in
            CCFetchMemberInfoUseCase(repository: resolver.resolve())
        }

        container.register(CCPurchaseMemberUseCase.self) { resolver in
            CCPurchaseMemberUseCase(repository: resolver.resolve())
        }

        container.register(CCFetchFeedsUseCase.self) { resolver in
            CCFetchFeedsUseCase(repository: resolver.resolve())
        }

        container.register(CCFetchMessagesUseCase.self) { resolver in
            CCFetchMessagesUseCase(repo: resolver.resolve())
        }
    }
}
