//
//  CCUserDefaultsManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCUserDefaultsKey: String, CaseIterable {
    case isFirstLaunch
    case isLoggedIn
    case userId
    case lastSyncDate
    case appTheme
    case language
    case fontSize
}

protocol CCUserDefaultsManagerProtocol {
    func set<T>(_ value: T, for key: CCUserDefaultsKey)
    func get<T>(_ key: CCUserDefaultsKey) -> T?
    func remove(_ key: CCUserDefaultsKey)
    func clear()
}

final class CCUserDefaultsManager: CCUserDefaultsManagerProtocol {
    private let defaults: UserDefaults

    init(suiteName: String? = nil) {
        if let suiteName = suiteName {
            defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            defaults = .standard
        }
    }

    func set<T>(_ value: T, for key: CCUserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    func get<T>(_ key: CCUserDefaultsKey) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }

    func remove(_ key: CCUserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    func clear() {
        CCUserDefaultsKey.allCases.forEach { remove($0) }
    }
}
