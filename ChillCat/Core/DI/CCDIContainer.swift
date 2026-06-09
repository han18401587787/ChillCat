//
//  CCDIContainer.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCDIContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping (CCDIContainerProtocol) -> T)
    func register<T>(_ type: T.Type, name: String, factory: @escaping (CCDIContainerProtocol) -> T)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping (CCDIContainerProtocol) -> T)
    func resolve<T>() -> T
    func resolve<T>(_ name: String) -> T?
    func isRegistered<T>(_ type: T.Type) -> Bool
}

final class CCDIContainer: CCDIContainerProtocol {
    private struct CCRegistration {
        let factory: (CCDIContainerProtocol) -> Any
        let isSingleton: Bool
    }

    private var registrations: [String: CCRegistration] = [:]
    private var singletons: [String: Any] = [:]
    private let lock = NSRecursiveLock()

    func register<T>(_ type: T.Type, factory: @escaping (CCDIContainerProtocol) -> T) {
        let key = String(describing: type)
        lock.withLock {
            registrations[key] = CCRegistration(factory: factory, isSingleton: false)
        }
    }

    func register<T>(_ type: T.Type, name: String, factory: @escaping (CCDIContainerProtocol) -> T) {
        let key = "\(String(describing: type))_\(name)"
        lock.withLock {
            registrations[key] = CCRegistration(factory: factory, isSingleton: false)
        }
    }

    func registerSingleton<T>(_ type: T.Type, factory: @escaping (CCDIContainerProtocol) -> T) {
        let key = String(describing: type)
        lock.withLock {
            registrations[key] = CCRegistration(factory: factory, isSingleton: true)
        }
    }

    func resolve<T>() -> T {
        let key = String(describing: T.self)

        return lock.withLock {
            if let singleton = singletons[key] as? T {
                return singleton
            }

            guard let registration = registrations[key] else {
                fatalError("❌ DI: \(key) 未注册，请先调用 register()")
            }

            let instance = registration.factory(self) as! T

            if registration.isSingleton {
                singletons[key] = instance
            }

            return instance
        }
    }

    func resolve<T>(_ name: String) -> T? {
        let key = "\(String(describing: T.self))_\(name)"
        return lock.withLock {
            guard let registration = registrations[key] else { return nil }
            return registration.factory(self) as? T
        }
    }

    func isRegistered<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return lock.withLock { registrations[key] != nil }
    }
}
