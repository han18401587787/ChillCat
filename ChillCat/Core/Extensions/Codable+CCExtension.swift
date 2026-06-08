//
//  Codable+CCExtension.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension Encodable {
    func cc_toJSONData(encoder: JSONEncoder = JSONEncoder()) -> Data? {
        try? encoder.encode(self)
    }

    func cc_toJSONString(encoder: JSONEncoder = JSONEncoder()) -> String? {
        guard let data = cc_toJSONData(encoder: encoder) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func cc_toDictionary(encoder: JSONEncoder = JSONEncoder()) -> [String: Any]? {
        guard let data = cc_toJSONData(encoder: encoder) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
