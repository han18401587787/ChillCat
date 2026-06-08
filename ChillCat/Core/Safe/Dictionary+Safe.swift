//
//  Dictionary+Safe.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension Dictionary {
    subscript(safe key: Key?) -> Value? {
        guard let key = key else { return nil }
        return self[key]
    }

    func safeValue(for key: Key?) -> Value? {
        guard let key = key else { return nil }
        return self[key]
    }
}
