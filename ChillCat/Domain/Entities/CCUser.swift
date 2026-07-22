//
//  CCUser.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCUser: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var email: String
    var avatarURL: URL?
    var phone: String?
    var gender: CCGender
    var birthday: Date?
    var createdAt: Date
    var updatedAt: Date

    // v3.0 统计字段 (Ardot 个人中心)
    var totalCheckins: Int?
    var streakDays: Int?
    var resonanceCount: Int?

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        avatarURL: URL? = nil,
        phone: String? = nil,
        gender: CCGender = .unknown,
        birthday: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        totalCheckins: Int? = nil,
        streakDays: Int? = nil,
        resonanceCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.phone = phone
        self.gender = gender
        self.birthday = birthday
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalCheckins = totalCheckins
        self.streakDays = streakDays
        self.resonanceCount = resonanceCount
    }
}

enum CCGender: Int, Codable {
    case unknown = 0
    case male = 1
    case female = 2

    var displayName: String {
        switch self {
        case .unknown: return "未设置"
        case .male: return "男"
        case .female: return "女"
        }
    }
}
