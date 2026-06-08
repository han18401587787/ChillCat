import Foundation
@testable import ChillCat

enum TestHelpers {
    static func makeUser(id: String = "1", name: String = "测试", email: String = "test@chillcat.app") -> CCUser {
        CCUser(id: id, name: name, email: email)
    }

    static func makeMemberInfo(isValid: Bool = true, type: CCMemberType = .monthly) -> CCMemberInfo {
        CCMemberInfo(
            id: "m1",
            userId: "1",
            memberType: type,
            status: isValid ? .active : .expired,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            autoRenew: true
        )
    }

    static func makeFeedItems(count: Int) -> [CCFeedItem] {
        (0..<count).map {
            CCFeedItem(id: "\($0)", title: "标题\($0)", subtitle: "副标题\($0)", imageURL: nil, contentType: "article")
        }
    }

    static func makeMessages(count: Int, isRead: Bool = false) -> [CCMessage] {
        (0..<count).map {
            CCMessage(id: "\($0)", title: "消息\($0)", content: "内容\($0)", msgType: "system", isRead: isRead, createdAt: "2026-06-08 12:00")
        }
    }

    static func makeProduct(type: CCMemberType = .monthly) -> CCMemberProduct {
        CCMemberProduct(id: "monthly", type: .monthly, price: 15, originalPrice: nil, displayPrice: "¥15.00", discountTag: nil)
    }
}
