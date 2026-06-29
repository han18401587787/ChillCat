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
}

struct CCVisionAnalyzeResult: Decodable {
    let score: Double
    let passed: Bool
    let issues: [CCVisionIssue]
    let elementsFound: [String]
    let elementsMissing: [String]
    let suggestion: String

    enum CodingKeys: String, CodingKey {
        case score
        case passed
        case issues
        case elementsFound = "elements_found"
        case elementsMissing = "elements_missing"
        case suggestion
    }
}
