//
//  CCLogEntry.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCLogEntry: Sendable, Codable {
    let timestamp: Date
    let level: String
    let module: String
    let category: String
    let message: String
    let traceID: String?
    let spanID: String?
    let file: String
    let function: String
    let line: Int
    let tags: [String: String]?
    let metadata: [String: String]?
    let error: CCLogErrorInfo?

    struct CCLogErrorInfo: Sendable, Codable {
        let domain: String
        let code: Int
        let description: String
        let stackTrace: String?
    }

    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func toReadableString() -> String {
        let dateStr = ISO8601DateFormatter().string(from: timestamp)
        var result = "\(dateStr) [\(level)] [\(module)] \(message)"
        if let traceID = traceID { result += " | trace:\(traceID)" }
        return result
    }
}
