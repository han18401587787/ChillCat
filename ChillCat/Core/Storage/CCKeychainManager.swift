//
//  CCKeychainManager.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import Security

protocol CCKeychainManagerProtocol {
    func set(_ value: String, for key: String) throws
    func set(_ data: Data, for key: String) throws
    func get(_ key: String) throws -> String?
    func getData(_ key: String) throws -> Data?
    func delete(_ key: String) throws
    func clear() throws
}

final class CCKeychainManager: CCKeychainManagerProtocol {
    private let service: String
    private let accessGroup: String?

    init(service: String = Bundle.main.bundleIdentifier ?? "com.chillcat",
         accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    func set(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw CCKeychainError.encodingFailed
        }
        try set(data, for: key)
    }

    func set(_ data: Data, for key: String) throws {
        try? delete(key)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CCKeychainError.saveFailed(status)
        }
    }

    func get(_ key: String) throws -> String? {
        guard let data = try getData(key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func getData(_ key: String) throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw CCKeychainError.readFailed(status)
        }

        return result as? Data
    }

    func delete(_ key: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CCKeychainError.deleteFailed(status)
        }
    }

    func clear() throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CCKeychainError.deleteFailed(status)
        }
    }
}

enum CCKeychainError: LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "数据编码失败"
        case .saveFailed(let status): return "Keychain 保存失败: \(status)"
        case .readFailed(let status): return "Keychain 读取失败: \(status)"
        case .deleteFailed(let status): return "Keychain 删除失败: \(status)"
        }
    }
}
