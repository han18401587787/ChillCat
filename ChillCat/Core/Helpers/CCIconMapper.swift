//
//  CCIconMapper.swift
//  ChillCat — SF Symbol → 自定义图标映射工具
//

import SwiftUI

/// SF Symbol → 自定义图标名的全局映射
/// 用于动态图标引用场景（如 CCIconMapper.image(for: variable)）
enum CCIconMapper {
    /// 将 SF Symbol 名称映射为自定义图标名
    /// 如果没有对应映射，返回 nil（调用方可 fallback 到 SF Symbol）
    static func customIcon(for sfSymbol: String) -> String? {
        switch sfSymbol {
        // 首页
        case "house.fill": return "home_home"
        case "brain.head.profile", "brain.head.profile.fill": return "home_mood"
        case "headphones": return "home_ai"
        case "sparkles": return "home_quote"
        case "checkmark.circle.fill": return "home_checkin"
        case "chart.line.uptrend.xyaxis": return "home_chart"
        case "square.grid.2x2.fill": return "home_apps"
        case "bolt.fill": return "emotion_hopeful"

        // 树洞
        case "bubble.left.and.bubble.right.fill": return "treehole_write"
        case "pencil.line": return "treehole_write"
        case "tag.fill": return "treehole_tag"
        case "person.crop.circle.badge.questionmark": return "treehole_anon"
        case "folder.fill": return "treehole_category"
        case "bubble.left.and.bubble.right": return "treehole_write"

        // 共鸣墙
        case "heart.fill": return "resonance_like"
        case "bubble.left": return "resonance_comment"
        case "person.2.fill": return "resonance_people"
        case "person.2": return "resonance_people"
        case "person.3.fill": return "resonance_people"
        case "text.bubble.fill": return "resonance_topic"
        case "heart.circle.fill": return "resonance_like"
        case "hand.wave.fill": return "resonance_like"

        // 治愈空间
        case "leaf.fill": return "healing_meditate"
        case "lungs.fill": return "healing_breath"
        case "moon.zzz.fill": return "healing_sound"
        case "eye.fill": return "healing_scan"
        case "book.fill": return "healing_course"
        case "bookmark.fill": return "healing_bookmark"
        case "heart.text.square.fill": return "healing_bookmark"
        case "figure.mind.and.body": return "healing_breath"
        case "speaker.wave.2.fill": return "healing_sound"
        case "waveform.circle": return "healing_sound"
        case "play.fill": return "healing_course"

        // AI 对话
        case "mic.fill": return "ai_listen"
        case "mic.slash.fill": return "ai_listen"
        case "lightbulb.fill": return "ai_think"
        case "clock.arrow.circlepath": return "ai_history"
        case "cat.fill": return "home_ai"

        // 情绪报告
        case "chart.bar.fill": return "report_overview"
        case "chart.bar.xaxis": return "report_trend"
        case "chart.bar.xaxis.ascending": return "report_trend"
        case "chart.pie.fill": return "report_pie"
        case "flag.fill": return "report_trigger"
        case "arrow.left.arrow.right": return "report_compare"
        case "square.and.arrow.up.fill": return "report_share"
        case "doc.text.fill": return "report_weekly"
        case "list.bullet.rectangle.portrait": return "report_overview"

        // 个人中心
        case "person.fill": return "profile_user"
        case "person.circle.fill": return "profile_user"
        case "person.crop.circle.fill": return "profile_user"
        case "crown.fill": return "profile_vip"
        case "chart.bar.doc.horizontal.fill": return "profile_data"
        case "target": return "profile_target"
        case "lock.shield.fill": return "profile_privacy"
        case "info.circle.fill", "info.circle": return "profile_about"
        case "questionmark.circle.fill": return "profile_help"
        case "rectangle.portrait.and.arrow.right": return "profile_logout"

        // 预警守护
        case "exclamationmark.triangle.fill", "exclamationmark.triangle": return "alert_warn"
        case "exclamationmark.circle.fill": return "alert_warn"
        case "exclamationmark.bubble.fill": return "alert_warn"
        case "shield.fill", "shield.checkered": return "alert_guardian"
        case "exclamationmark.shield.fill": return "alert_guardian"
        case "heart.text.clinic.fill": return "alert_guardian"
        case "phone.fill", "phone.circle.fill", "phone.arrow.up.right": return "alert_call"
        case "hand.raised.fill": return "alert_help"
        case "cross.case.fill": return "alert_risk"

        // 通用操作
        case "chevron.left": return "common_back"
        case "chevron.right", "chevron.compact.down": return "common_more"
        case "magnifyingglass": return "common_search"
        case "bell.fill": return "common_bell"
        case "gearshape.fill", "gearshape.2.fill": return "common_settings"
        case "ellipsis", "ellipsis.circle", "line.3.horizontal": return "common_more"
        case "xmark", "xmark.circle.fill": return "common_close"
        case "plus.circle.fill": return "common_add"
        case "pencil", "pencil.circle", "pencil.circle.fill": return "common_edit"
        case "square.and.arrow.up", "arrow.up.circle.fill", "arrow.up.forward.app.fill": return "common_share"
        case "arrowshape.turn.up.forward.fill": return "common_share"
        case "trash", "trash.fill": return "common_delete"
        case "line.3.horizontal.decrease.fill": return "common_filter"
        case "arrow.clockwise", "arrow.counterclockwise": return "common_refresh"
        case "forward.fill", "gobackward.15", "goforward.15": return "common_refresh"
        case "arrow.right", "arrow.right.circle.fill", "arrowtriangle.down.fill": return "common_more"
        case "checkmark": return "home_checkin"
        case "paperplane.fill": return "common_share"
        case "timer": return "other_assess"

        // 情绪
        case "face.smiling", "face.smiling.fill": return "emotion_happy"
        case "sun.max.fill": return "emotion_happy"
        case "leaf.circle.fill": return "emotion_calm"
        case "cloud.fill", "cloud.rain.fill": return "emotion_sad"
        case "tornado": return "emotion_anxious"
        case "flame.fill": return "emotion_angry"
        case "star.fill": return "emotion_hopeful"
        case "emotion_tired": return "emotion_tired"
        case "emotion_grateful": return "emotion_grateful"

        // 其他
        case "calendar": return "other_calendar"
        case "graduationcap.fill": return "other_knowledge"
        case "square.and.arrow.down.fill": return "other_download"
        case "checklist": return "other_assess"
        case "book.closed.fill", "book.pages", "book.pages.fill": return "other_diary"
        case "note.text": return "other_diary"
        case "map.fill", "compass.drawing": return "other_map"
        case "envelope.fill", "envelope.open.fill", "message.fill": return "other_mail"
        case "doc.text.magnifyingglass": return "common_search"

        // 无映射 — 返回 nil，调用方保留 SF Symbol
        default: return nil
        }
    }

    /// 创建 Image：优先使用自定义图标，不存在则 fallback 到 SF Symbol
    static func image(for sfSymbol: String) -> Image {
        if let custom = customIcon(for: sfSymbol) {
            return Image(custom)
        }
        return Image(systemName: sfSymbol)
    }
}
