//
//  CCUserDTO.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import Foundation

/// 服务端 /api/v1/auth/login 返回:
/// {"user_id":35,"username":"tester","nickname":"测试员","avatar":"...","token":"..."}
/// keyDecodingStrategy = .convertFromSnakeCase → user_id→userId, 但 DTO 需匹配
struct CCUserDTO: Decodable {
    let userId: Int64
    let username: String
    let nickname: String?
    let avatar: String?
    let token: String?

    // 兼容旧版 login/register 返回结构
    let id: String?
    let nickName: String?
    let email: String?
    let phone: String?
    let gender: Int?
    let birthday: String?
    let createdAt: String?
    let updatedAt: String?
}

enum CCUserDTOMapper {
    static func toEntity(_ dto: CCUserDTO) -> CCUser {
        CCUser(
            id: String(dto.userId),
            name: dto.nickname ?? dto.nickName ?? dto.username,
            email: dto.email ?? "",
            avatarURL: dto.avatar.flatMap { URL(string: $0) },
            phone: dto.phone,
            gender: CCGender(rawValue: dto.gender ?? 0) ?? .unknown,
            birthday: dto.birthday.flatMap { Date.cc_fromISO8601($0) },
            createdAt: dto.createdAt.flatMap { Date.cc_fromISO8601($0) } ?? Date(),
            updatedAt: dto.updatedAt.flatMap { Date.cc_fromISO8601($0) } ?? Date()
        )
    }
}
