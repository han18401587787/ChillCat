//
//  String+CCExtension.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension String {
    var cc_isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    var cc_isValidPhone: Bool {
        let regex = "^1[3-9]\\d{9}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    var cc_trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cc_urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    func cc_toJSON<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    var cc_maskedPhone: String {
        guard cc_isValidPhone else { return self }
        let start = index(startIndex, offsetBy: 3)
        let end = index(startIndex, offsetBy: 7)
        return replacingCharacters(in: start..<end, with: "****")
    }

    static var cc_empty: String { "" }
}
