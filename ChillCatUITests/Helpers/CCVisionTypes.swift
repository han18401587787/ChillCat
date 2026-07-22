//
//  CCVisionTypes.swift
//  ChillCat
//
//  Created by doudou.han on 2026-06-26
//

import Foundation

// MARK: - Vision 视觉分析类型（独立文件，确保 test target 可链接）

struct CCVisionAnalyzeRequest: Encodable {
    let image: String
    let page: String
    let checks: [String]
}

struct CCVisionIssue: Decodable {
    let type: String
    let description: String
    let severity: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = (try? container.decode(String.self, forKey: .type)) ?? "unknown"
        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        severity = (try? container.decode(String.self, forKey: .severity)) ?? "info"
    }

    private enum CodingKeys: String, CodingKey {
        case type, description, severity
    }
}

struct CCVisionAnalyzeResult: Decodable {
    let score: Double
    let passed: Bool
    let issues: [CCVisionIssue]
    let elementsFound: [String]
    let elementsMissing: [String]
    let suggestion: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        score = (try? container.decode(Double.self, forKey: .score)) ?? 0
        passed = (try? container.decode(Bool.self, forKey: .passed)) ?? false
        issues = (try? container.decode([CCVisionIssue].self, forKey: .issues)) ?? []
        elementsFound = (try? container.decode([String].self, forKey: .elementsFound)) ?? []
        elementsMissing = (try? container.decode([String].self, forKey: .elementsMissing)) ?? []
        suggestion = (try? container.decode(String.self, forKey: .suggestion)) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case score
        case passed
        case issues
        case elementsFound = "elements_found"
        case elementsMissing = "elements_missing"
        case suggestion
    }
}
