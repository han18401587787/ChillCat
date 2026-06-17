import SwiftUI
struct CCUserAgreementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:AppSpacing.md) {
                Text("绪安用户协议").font(.system(size:22,weight:.bold))
                Text("更新日期：2026年6月").font(.system(size:13)).foregroundColor(AppTheme.textMuted)
                section("一、服务说明","绪安是一款情绪自愈App，提供情绪记录、冥想练习、树洞社区等功能。本协议是您与绪安之间关于使用服务的法律协议。")
                section("二、账号管理","您可以通过匿名方式使用绪安，无需提供个人身份信息。匿名账号仅保存在本地设备，更换设备后无法恢复。您也可以注册正式账号以同步数据。")
                section("三、内容规范","树洞社区鼓励温暖、包容的表达。禁止发布违法、暴力、骚扰或侵犯他人权益的内容。我们保留移除违规内容的权利。")
                section("四、隐私保护","我们承诺保护您的隐私。情绪日记默认仅自己可见，树洞帖子默认匿名。详细说明请参阅《隐私政策》。")
                section("五、免责声明","绪安不提供医疗诊断或治疗建议。如果您持续感到严重情绪困扰，请寻求专业心理帮助。")
                section("六、协议更新","我们可能不时更新本协议，重大变更会通过App通知您。继续使用即视为同意更新后的协议。")
            }.padding()
        }.background(AppTheme.background).navigationTitle("用户协议")
    }
    func section(_ title:String,_ body:String) -> some View {
        VStack(alignment:.leading,spacing:8){
            Text(title).font(.system(size:16,weight:.semibold))
            Text(body).font(.system(size:14)).foregroundColor(AppTheme.textSecondary).lineSpacing(6)
        }.padding(.bottom,8)
    }
}
