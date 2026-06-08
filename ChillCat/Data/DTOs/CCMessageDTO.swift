//
//  CCMessageDTO.swift
//  ChillCat
//

import Foundation

struct CCMessageDTO: Decodable {
    let id: Int64
    let title: String
    let content: String
    let msg_type: String
    let is_read: Bool
    let created_at: String
}

struct CCMessageListDTO: Decodable {
    let list: [CCMessageDTO]
    let total: Int64
    let page: Int
    let page_size: Int
}

struct CCUnreadCountDTO: Decodable {
    let count: Int64
}

enum CCMessageDTOMapper {
    static func toEntity(_ dto: CCMessageDTO) -> CCMessage {
        CCMessage(
            id: String(dto.id),
            title: dto.title,
            content: dto.content,
            msgType: dto.msg_type,
            isRead: dto.is_read,
            createdAt: dto.created_at
        )
    }
}
