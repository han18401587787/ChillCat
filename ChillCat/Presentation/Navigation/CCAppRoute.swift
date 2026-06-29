//
//  CCAppRoute.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import SwiftUI

/// Type bridge used by the resonance detail route — mirrors CCResonancePost
struct CCResonanceDisplayItem: Hashable, Identifiable {
    let id: String; let content: String; let emotion: String
    let emotionColor: String; let isAnonymous: Bool
    let displayName: String; var resonanceCount: Int; let createdAt: Date

    var emotionColorValue: Color { Color(hex: emotionColor) }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }
        return "\(Int(d/86400))天前"
    }

    static var demoItems: [CCResonanceDisplayItem] = [
        .init(id: "1", content: "三十岁生日一个人过的，给自己买了个小蛋糕。有点孤独，但也挺自由的。",
              emotion: "孤独", emotionColor: "7A9AAA",
              isAnonymous: true, displayName: "匿名用户",
              resonanceCount: 2341, createdAt: Date().addingTimeInterval(-7200)),
        .init(id: "2", content: "下周一就答辩了，PPT改了三遍了还是不满意。",
              emotion: "焦虑", emotionColor: "D4C8E8",
              isAnonymous: true, displayName: "匿名用户",
              resonanceCount: 892, createdAt: Date().addingTimeInterval(-18000)),
        .init(id: "3", content: "今天终于鼓起勇气和妈妈说了心里话。说着说着就哭了，但说完轻松了好多好多。",
              emotion: "平静", emotionColor: "66BB6A",
              isAnonymous: true, displayName: "匿名用户",
              resonanceCount: 1567, createdAt: Date().addingTimeInterval(-3600)),
        .init(id: "4", content: "在地铁上看到一个女孩偷偷擦眼泪，想递张纸巾又怕冒犯。希望你现在好一点了。",
              emotion: "委屈", emotionColor: "E8B8C8",
              isAnonymous: true, displayName: "匿名用户",
              resonanceCount: 3201, createdAt: Date().addingTimeInterval(-5400)),
    ]
}

enum CCAppRoute: Hashable, Identifiable {
    case login
    case home
    case treeHole
    case voiceCheckin
    case voiceDiary
    case journal
    case trends
    case meditation
    case courses
    case vipCenter
    case transactionHistory
    case profile
    case privacy
    case dataManagement
    case faq
    case deleteAccount
    case postDetail(CCTreeHolePost)
    case aiListener
    case resonanceWall
    case resonanceDetail(CCResonanceDisplayItem)
    case encourageChain
    case encourageChainDetail(chainId: Int64)
    case myEncourageChains
    case emotionDecoder
    case voiceEmotionDiary
    case courseDetail(CCXuanAPI.CourseItem)
    case journalDetail(CCXuanAPI.JournalEntry)
    case feedback
    case userAgreement
    case privacyPolicy
    case settings
    case meditationPlayer(session: CCMeditationSession)
    case web(url: URL)
    case professionalResources
    case safetyPlan
    case crisisHotline
    case toolbox
    case breathingExercise
    case cbtRestructuring
    case progressiveMuscleRelaxation
    case bodyScan
    case valuesExplorer
    case gratitudeJournal
    case behavioralActivation
    case healing
    case growthArchive
    case growthReport
    case mutualAidGroups
    case mutualAidGroupDetail(Int64)
    case stablePlan
    case rainSound
    case emotionRecord
    case checkinSuccess

    var id: String {
        switch self {
        case .login: return "login"
        case .home: return "home"
        case .treeHole: return "treeHole"
        case .voiceCheckin: return "voiceCheckin"
        case .voiceDiary: return "voiceDiary"
        case .journal: return "journal"
        case .trends: return "trends"
        case .meditation: return "meditation"
        case .courses: return "courses"
        case .vipCenter: return "vipCenter"
        case .transactionHistory: return "transactionHistory"
        case .profile: return "profile"
        case .privacy: return "privacy"
        case .dataManagement: return "dataManagement"
        case .faq: return "faq"
        case .deleteAccount: return "deleteAccount"
        case .postDetail(let p): return "postDetail_\(p.id)"
        case .aiListener: return "aiListener"
        case .resonanceWall: return "resonanceWall"
        case .resonanceDetail(let r): return "resonanceDetail_\(r.id)"
        case .encourageChain: return "encourageChain"
        case .encourageChainDetail(let chainId): return "encourageChainDetail_\(chainId)"
        case .myEncourageChains: return "myEncourageChains"
        case .emotionDecoder: return "emotionDecoder"
        case .voiceEmotionDiary: return "voiceEmotionDiary"
        case .courseDetail(let c): return "courseDetail_\(c.id)"
        case .journalDetail(let e): return "journalDetail_\(e.id)"
        case .feedback: return "feedback"
        case .userAgreement: return "userAgreement"
        case .privacyPolicy: return "privacyPolicy"
        case .settings: return "settings"
        case .meditationPlayer(let session): return "meditationPlayer_\(session.id)"
        case .web(let url): return "web_\(url.absoluteString)"
        case .professionalResources: return "professionalResources"
        case .safetyPlan: return "safetyPlan"
        case .crisisHotline: return "crisisHotline"
        case .toolbox: return "toolbox"
        case .breathingExercise: return "breathingExercise"
        case .cbtRestructuring: return "cbtRestructuring"
        case .progressiveMuscleRelaxation: return "progressiveMuscleRelaxation"
        case .bodyScan: return "bodyScan"
        case .valuesExplorer: return "valuesExplorer"
        case .gratitudeJournal: return "gratitudeJournal"
        case .behavioralActivation: return "behavioralActivation"
        case .healing: return "healing"
        case .growthArchive: return "growthArchive"
        case .growthReport: return "growthReport"
        case .mutualAidGroups: return "mutualAidGroups"
        case .mutualAidGroupDetail(let id): return "mutualAidGroupDetail_\(id)"
        case .stablePlan: return "stablePlan"
        case .rainSound: return "rainSound"
        case .emotionRecord: return "emotionRecord"
        case .checkinSuccess: return "checkinSuccess"
        }
    }
}
