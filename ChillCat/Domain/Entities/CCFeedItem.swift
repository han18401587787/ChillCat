//
//  CCFeedItem.swift
//  ChillCat
//

import Foundation

struct CCFeedItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let imageURL: URL?
    let contentType: String
}

extension CCFeedItem {
    var imageName: String {
        switch contentType {
        case "video": return "play.rectangle.fill"
        case "music": return "music.note.list"
        case "article": return "doc.text.fill"
        default: return "photo.fill"
        }
    }
}
