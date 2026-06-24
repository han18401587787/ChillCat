import Foundation

struct CCMutualAidGroup: Identifiable, Codable, Equatable {
    let id: Int64
    let name: String
    let description: String
    let category: String
    let memberCount: Int64
    let iconName: String
    var isJoined: Bool

    static let presetGroups: [CCMutualAidGroup] = [
        .init(id: 1, name: "焦虑陪伴", description: "一起面对焦虑，互相支持", category: "情绪", memberCount: 2341, iconName: "wind", isJoined: false),
        .init(id: 2, name: "抑郁支持", description: "温暖陪伴，走出阴霾", category: "情绪", memberCount: 1892, iconName: "cloud.rain.fill", isJoined: false),
        .init(id: 3, name: "职场压力", description: "工作中的情绪管理", category: "生活", memberCount: 3156, iconName: "briefcase.fill", isJoined: false),
        .init(id: 4, name: "亲密关系", description: "爱与成长的路上", category: "关系", memberCount: 2789, iconName: "heart.circle.fill", isJoined: false),
        .init(id: 5, name: "自我成长", description: "探索内心，成为更好的自己", category: "成长", memberCount: 4521, iconName: "leaf.fill", isJoined: false),
        .init(id: 6, name: "失恋恢复", description: "温柔度过分手期", category: "关系", memberCount: 1678, iconName: "heart.slash.fill", isJoined: false),
        .init(id: 7, name: "学业压力", description: "考试、论文、未来规划", category: "生活", memberCount: 2034, iconName: "book.fill", isJoined: false),
        .init(id: 8, name: "睡眠改善", description: "告别失眠，拥抱好梦", category: "健康", memberCount: 1890, iconName: "moon.zzz.fill", isJoined: false),
    ]
}
