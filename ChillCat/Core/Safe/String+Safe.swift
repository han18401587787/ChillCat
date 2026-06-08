//
//  String+Safe.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension String {
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    subscript(safe range: Range<Int>) -> Substring? {
        guard range.lowerBound >= 0, range.upperBound <= count else { return nil }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }

    func safeSubstring(from index: Int) -> String? {
        guard index >= 0, index < count else { return nil }
        return String(self[self.index(startIndex, offsetBy: index)...])
    }

    func safeSubstring(to index: Int) -> String? {
        guard index >= 0, index <= count else { return nil }
        return String(self[..<self.index(startIndex, offsetBy: index)])
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}
