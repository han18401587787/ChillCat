//
//  CCAIEmpathy.swift
//  绪安 - AI 情绪倾听官 实体
//

import Foundation

/// AI 倾听官回复
struct CCAIEmpathyResponse: Identifiable {
    let id: Int
    let text: String
    var isHelpful: Bool?
}

/// AI 倾听官状态
enum CCAIEmpathyState {
    case idle
    case loading
    case showingResponses([CCAIEmpathyResponse])
    case error
}
