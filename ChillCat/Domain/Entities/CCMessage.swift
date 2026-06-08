//
//  CCMessage.swift
//  ChillCat
//

import Foundation

struct CCMessage: Identifiable, Equatable {
    let id: String
    let title: String
    let content: String
    let msgType: String
    let isRead: Bool
    let createdAt: String
}
