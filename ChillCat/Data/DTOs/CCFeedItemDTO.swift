//
//  CCFeedItemDTO.swift
//  ChillCat
//

import Foundation

struct CCFeedItemDTO: Decodable {
    let id: Int64
    let title: String
    let subtitle: String
    let image_url: String?
    let content_type: String
}

struct CCFeedListDTO: Decodable {
    let list: [CCFeedItemDTO]
    let total: Int64
    let page: Int
    let page_size: Int
}

enum CCFeedDTOMapper {
    static func toEntity(_ dto: CCFeedItemDTO) -> CCFeedItem {
        CCFeedItem(
            id: String(dto.id),
            title: dto.title,
            subtitle: dto.subtitle,
            imageURL: dto.image_url.flatMap { URL(string: $0) },
            contentType: dto.content_type
        )
    }
}
