import SwiftUI

struct CCCoursesView: View {
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                Text("小课堂").font(.system(size: 24, weight: .bold))

                categorySection(title: "情绪管理", icon: "heart.text.clipboard.fill", color: Color(hex: "D4C8E8"), courses: [
                    CCCourse(title: "如何在职场中设置情绪边界", duration: "8 分钟", tag: "职场场景"),
                    CCCourse(title: "情绪爆发之后，怎么修复关系？", duration: "6 分钟", tag: "恋爱情绪"),
                    CCCourse(title: "自我接纳：允许自己偶尔脆弱", duration: "5 分钟", tag: "成长"),
                ])
                categorySection(title: "焦虑治愈", icon: "leaf.circle.fill", color: Color(hex: "D5E8D4"), courses: [
                    CCCourse(title: "你通常在周三情绪最低", duration: "4 分钟", tag: "情绪管理"),
                    CCCourse(title: "独居场景：一个人的放松指南", duration: "7 分钟", tag: "独居场景"),
                ])
                categorySection(title: "睡前助眠", icon: "moon.stars.fill", color: Color(hex: "B8D4E3"), courses: [
                    CCCourse(title: "睡前记录：今天想说…", duration: "3 分钟", tag: "睡前助眠"),
                    CCCourse(title: "呼吸训练入门", duration: "5 分钟", tag: "练习计划"),
                ])
            }.padding()
        }.background(theme.background).navigationTitle("小课堂")
    }

    func categorySection(title: String, icon: String, color: Color, courses: [CCCourse]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            HStack { Image(systemName: icon).foregroundColor(color); Text(title).font(.system(size: 18, weight: .semibold)) }
            ForEach(courses) { course in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(course.title).font(.system(size: 15, weight: .medium))
                        HStack(spacing: 8) {
                            Text(course.tag).font(.system(size: 11)).foregroundColor(Color(hex: "5A7A8A"))
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Color(hex: "B8D4E3").opacity(0.3)).cornerRadius(4)
                            Text(course.duration).font(.system(size: 11)).foregroundColor(theme.textMuted)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(theme.textMuted)
                }.padding().background(theme.cardBackground).cornerRadius(theme.radiusMD)
            }
        }
    }
}

struct CCCourse: Identifiable, Hashable {
    let id = UUID(); let title: String; let duration: String; let tag: String
}
