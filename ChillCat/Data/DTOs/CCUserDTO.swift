//
//  CCUserDTO.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

struct CCUserDTO: Decodable {
    let id: String
    let nickName: String
    let email: String
    let avatar: String?
    let phone: String?
    let gender: Int?
    let birthday: String?
    let createdAt: String
    let updatedAt: String
}

enum CCUserDTOMapper {
    static func toEntity(_ dto: CCUserDTO) -> CCUser {
        CCUser(
            id: dto.id,
            name: dto.nickName,
            email: dto.email,
            avatarURL: dto.avatar.flatMap { URL(string: $0) },
            phone: dto.phone,
            gender: CCGender(rawValue: dto.gender ?? 0) ?? .unknown,
            birthday: dto.birthday.flatMap { Date.cc_fromISO8601($0) },
            createdAt: Date.cc_fromISO8601(dto.createdAt) ?? Date(),
            updatedAt: Date.cc_fromISO8601(dto.updatedAt) ?? Date()
        )
    }
}
