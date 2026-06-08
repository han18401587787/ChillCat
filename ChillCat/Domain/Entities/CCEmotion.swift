//
//  CCEmotion.swift
//  绪安
//

import Foundation

enum CCEmotion: String, CaseIterable, Identifiable, Codable, Hashable {
    case calm     = "平静"
    case happy    = "开心"
    case tired    = "疲惫"
    case anxious  = "焦虑"
    case wronged  = "委屈"
    case lonely   = "孤独"
    case irritable = "烦躁"
    case confused = "迷茫"
    case anger    = "易怒"
    case drained  = "内耗"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .calm:     return "leaf.fill"
        case .happy:    return "sun.max.fill"
        case .tired:    return "moon.zzz.fill"
        case .anxious:  return "tornado"
        case .wronged:  return "drop.fill"
        case .lonely:   return "cloud.fill"
        case .irritable: return "flame.fill"
        case .confused: return "questionmark.circle.fill"
        case .anger:    return "burst.fill"
        case .drained:  return "battery.25percent"
        }
    }

    var colorName: String {
        switch self {
        case .calm:     return "softGreen"
        case .happy:    return "warmLight"
        case .tired:    return "primaryMuted"
        case .anxious:  return "softPurple"
        case .wronged:  return "softPink"
        case .lonely:   return "primaryLight"
        case .irritable: return "error"
        case .confused: return "softPurpleLight"
        case .anger:    return "warm"
        case .drained:  return "textMuted"
        }
    }
}
