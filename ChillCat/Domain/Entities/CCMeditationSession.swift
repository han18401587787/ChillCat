//
//  CCMeditationSession.swift
//  ChillCat
//
//  冥想音频会话模型
//

import Foundation

enum CCMeditationCategory: String, CaseIterable, Hashable, Codable {
    case sleep
    case relax
    case anxiety

    var displayName: String {
        switch self {
        case .sleep: return "睡前助眠"
        case .relax: return "独处放松"
        case .anxiety: return "焦虑治愈"
        }
    }

    var iconName: String {
        switch self {
        case .sleep: return "moon.zzz.fill"
        case .relax: return "brain.head.profile"
        case .anxiety: return "leaf.fill"
        }
    }

    var themeColor: String {
        switch self {
        case .sleep: return "D4C8E8"
        case .relax: return "B8D4E3"
        case .anxiety: return "D5E8D4"
        }
    }

    var toneFrequency: Double {
        switch self {
        case .sleep: return 174.0     // Solfeggio calming
        case .relax: return 285.0     // Tissue restoration
        case .anxiety: return 396.0   // Liberating guilt/fear
        }
    }

    var subtitle: String {
        switch self {
        case .sleep: return "约需 2 分钟"
        case .relax: return "约需 5 分钟"
        case .anxiety: return "约需 3 分钟"
        }
    }
}

struct CCMeditationSession: Hashable, Identifiable {
    let id: String
    let title: String
    let audioURL: URL
    let duration: TimeInterval
    let category: CCMeditationCategory

    init(
        id: String = UUID().uuidString,
        title: String,
        audioURL: URL,
        duration: TimeInterval,
        category: CCMeditationCategory
    ) {
        self.id = id
        self.title = title
        self.audioURL = audioURL
        self.duration = duration
        self.category = category
    }

    /// 预设的三套冥想课程
    static let presets: [CCMeditationSession] = {
        let tempDir = FileManager.default.temporaryDirectory
        return [
            CCMeditationSession(
                id: "preset_sleep",
                title: "睡前助眠",
                audioURL: tempDir.appendingPathComponent("chillcat_sleep.wav"),
                duration: 120,
                category: .sleep
            ),
            CCMeditationSession(
                id: "preset_relax",
                title: "独处放松",
                audioURL: tempDir.appendingPathComponent("chillcat_relax.wav"),
                duration: 300,
                category: .relax
            ),
            CCMeditationSession(
                id: "preset_anxiety",
                title: "焦虑治愈",
                audioURL: tempDir.appendingPathComponent("chillcat_anxiety.wav"),
                duration: 180,
                category: .anxiety
            )
        ]
    }()
}
