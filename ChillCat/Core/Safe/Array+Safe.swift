//
//  Array+Safe.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }

    subscript(safe range: Range<Int>) -> ArraySlice<Element> {
        let start = Swift.max(0, range.lowerBound)
        let end = Swift.min(count, range.upperBound)
        guard start < end else { return [] }
        return self[start..<end]
    }

    mutating func safeAppend(_ element: Element?) {
        guard let element = element else { return }
        append(element)
    }

    mutating func safeInsert(_ element: Element?, at index: Int) {
        guard let element = element, index >= 0, index <= count else { return }
        insert(element, at: index)
    }

    mutating func safeRemove(at index: Int) {
        guard index >= 0, index < count else { return }
        remove(at: index)
    }
}
