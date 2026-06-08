//
//  CCMemberLocalDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCMemberLocalDataSource {
    private let userDefaults: UserDefaults
    private let memberInfoKey = "cc_cached_member_info"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func cacheMemberInfo(_ info: CCMemberInfo) throws {
        let data = try JSONEncoder().encode(info)
        userDefaults.set(data, forKey: memberInfoKey)
    }

    func getCachedMemberInfo() throws -> CCMemberInfo? {
        guard let data = userDefaults.data(forKey: memberInfoKey) else { return nil }
        return try JSONDecoder().decode(CCMemberInfo.self, from: data)
    }

    func clearCache() {
        userDefaults.removeObject(forKey: memberInfoKey)
    }
}
