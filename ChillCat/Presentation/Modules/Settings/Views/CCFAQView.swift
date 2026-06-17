import SwiftUI

struct CCFAQView: View {

    var body: some View {
        List {
            faqSection(q: "绪安是什么？", a: "绪安是一款情绪自愈App，帮助你记录每日情绪、通过冥想放松、匿名树洞倾诉来温柔治愈自己。")
            faqSection(q: "我的数据安全吗？", a: "所有日记和语音数据均端到端加密存储，匿名模式下不会关联任何个人身份信息。")
            faqSection(q: "会员有哪些权益？", a: "会员可解锁全部冥想课程、情绪趋势深度分析、无限树洞发布和专属客服。")
            faqSection(q: "如何注销账号？", a: "前往「设置 → 注销账号」，注销后有7天撤销期。逾期所有数据将被永久删除。")
            faqSection(q: "树洞是什么？", a: "树洞是一个匿名倾诉社区。你可以随便说什么，没有评判，只有温柔回应。")
        }
        .navigationTitle("常见问题")
        .background(AppTheme.background)
    }

    func faqSection(q: String, a: String) -> some View {
        Section {
            Text(a).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary).lineSpacing(4)
        } header: {
            Text(q).font(.system(size: 15, weight: .medium)).foregroundColor(AppTheme.textPrimary)
        }
    }
}
