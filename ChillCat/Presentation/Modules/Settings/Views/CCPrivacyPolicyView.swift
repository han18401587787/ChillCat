import SwiftUI
struct CCPrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:XuanSpacing.md) {
                Text("绪安隐私政策").font(.system(size:22,weight:.bold))
                Text("更新日期：2026年6月").font(.system(size:13)).foregroundColor(Color.xuanTextTertiary)
                section("一、信息收集","匿名模式下，我们不收集任何个人身份信息。注册账号时，我们仅收集您主动提供的用户名、邮箱。情绪打卡数据加密存储于服务器。")
                section("二、数据使用","您的情绪数据仅用于提供个性化洞察和建议。匿名统计数据可能用于改善服务质量，不包含个人身份信息。")
                section("三、数据存储与安全","所有数据采用端到端加密传输和存储。服务器位于中国大陆，遵守《个人信息保护法》。")
                section("四、数据共享","我们不会向任何第三方出售、交易或转让您的个人数据。法律要求或保护我们合法权益的情况除外。")
                section("五、您的权利","您可以随时导出、修改或删除您的所有数据。注销账号后数据保留7天，在此期间可以撤销。")
                section("六、联系我们","如有隐私相关问题，请通过「设置→意见反馈」联系我们。")
            }.padding()
        }.background(Color.xuanApricotBg).navigationTitle("隐私政策")
    }
    func section(_ title:String,_ body:String) -> some View {
        VStack(alignment:.leading,spacing:8){
            Text(title).font(.system(size:16,weight:.semibold))
            Text(body).font(.system(size:14)).foregroundColor(Color.xuanTextSecondary).lineSpacing(6)
        }.padding(.bottom,8)
    }
}
