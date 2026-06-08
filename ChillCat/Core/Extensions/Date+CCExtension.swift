//
//  Date+CCExtension.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

extension Date {
    var cc_isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var cc_isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var cc_isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    func cc_formatted(_ format: String = CCConstants.defaultDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var cc_iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }

    static func cc_fromISO8601(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }

    var cc_dayStart: Date {
        Calendar.current.startOfDay(for: self)
    }

    var cc_timeAgo: String {
        let interval = abs(timeIntervalSinceNow)
        switch interval {
        case 0..<60: return "刚刚"
        case 60..<3600: return "\(Int(interval / 60)) 分钟前"
        case 3600..<86400: return "\(Int(interval / 3600)) 小时前"
        case 86400..<604800: return "\(Int(interval / 86400)) 天前"
        default: return cc_formatted("MM-dd HH:mm")
        }
    }
}
