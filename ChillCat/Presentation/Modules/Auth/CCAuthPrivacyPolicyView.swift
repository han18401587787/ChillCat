import SwiftUI

// MARK: - 隐私政策页面
/// 绪安 v3.0 隐私政策展示页面
/// App Store 审核强制要求：App 内必须可访问隐私政策
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 最后更新日期
                    Text("最后更新日期：2026年6月17日")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    PrivacySection(title: "一、信息收集") {
                        PrivacyItem("我们会收集您主动提供的信息，包括：")
                        BulletList([
                            "账户信息：手机号码（用于注册和登录）",
                            "情绪数据：您记录的语音日记、情绪标签、情绪强度评估",
                            "交互数据：AI对话内容、共鸣墙发布内容、鼓励链传递内容",
                            "设备信息：设备型号、操作系统版本、网络状态（用于优化服务体验）",
                        ])
                    }
                    
                    PrivacySection(title: "二、信息使用") {
                        PrivacyItem("我们使用收集的信息用于以下目的：")
                        BulletList([
                            "提供 AI 情绪分析和共情回应服务",
                            "生成个性化稳情计划推荐",
                            "改善 AI 模型的服务质量",
                            "保障平台安全和危机干预",
                            "遵守法律法规要求",
                        ])
                    }
                    
                    PrivacySection(title: "三、数据加密与存储") {
                        PrivacyItem("您的数据安全是我们的首要任务：")
                        BulletList([
                            "日记内容采用 AES-256-GCM 加密存储",
                            "数据传输全程使用 HTTPS + Certificate Pinning",
                            "密码使用 bcrypt(cost=12) 哈希存储，不可逆",
                            "服务器部署在中国大陆，遵守《个人信息保护法》",
                        ])
                    }
                    
                    PrivacySection(title: "四、匿名化保护") {
                        PrivacyItem("在以下场景中，您的身份将被匿名化处理：")
                        BulletList([
                            "共鸣墙发布：显示为随机匿名昵称",
                            "鼓励链传递：仅显示链上编号",
                            "情绪数据统计：用于产品改进时去除个人标识",
                        ])
                    }
                    
                    PrivacySection(title: "五、AI 服务说明") {
                        PrivacyItem("绪安使用 AI 技术提供服务，请注意：")
                        BulletList([
                            "AI 回应由大语言模型生成，仅供参考",
                            "AI 不提供医疗诊断、心理治疗或危机干预服务",
                            "如果您有自伤或自杀念头，请立即拨打心理援助热线",
                            "我们会对 AI 生成内容进行安全审核",
                        ])
                    }
                    
                    PrivacySection(title: "六、危机干预") {
                        PrivacyItem("当系统检测到高风险内容时，我们将：")
                        BulletList([
                            "暂停 AI 对话，展示专业心理援助热线",
                            "向运营团队发送告警（仅限必要信息）",
                            "24 小时后发送关怀推送",
                            "不会向第三方泄露您的危机状态",
                        ])
                    }
                    
                    PrivacySection(title: "七、您的权利") {
                        PrivacyItem("根据《个人信息保护法》，您享有以下权利：")
                        BulletList([
                            "查阅、复制您的个人信息",
                            "更正不准确的个人信息",
                            "删除您的账户和所有关联数据",
                            "撤回同意（在设置中管理权限）",
                            "注销账户（所有数据将被永久删除）",
                        ])
                    }
                    
                    PrivacySection(title: "八、未成年人保护") {
                        PrivacyItem("我们特别重视未成年人的隐私保护：")
                        BulletList([
                            "未满 14 周岁的用户需在监护人同意下使用",
                            "我们不会主动收集未成年人的个人信息",
                            "监护人可要求我们删除未成年人的信息",
                        ])
                    }
                    
                    PrivacySection(title: "九、联系我们") {
                        VStack(alignment: .leading, spacing: 8) {
                            PrivacyItem("如果您对隐私政策有任何疑问：")
                            ContactRow(icon: "envelope", text: "privacy@xuanapp.com")
                            ContactRow(icon: "globe", text: "https://xuanapp.com/privacy")
                        }
                    }
                    
                    // 心理援助热线
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🆘 心理援助热线")
                            .font(XuanFont.h3)
                            .foregroundColor(Color.xuanApricot)
                        
                        CrisisHotlineRow(name: "全国心理援助热线", number: "400-161-9995")
                        CrisisHotlineRow(name: "北京心理危机研究与干预中心", number: "010-82951332")
                        CrisisHotlineRow(name: "生命热线", number: "400-821-1215")
                        CrisisHotlineRow(name: "青少年心理援助热线", number: "12355")
                    }
                    .padding()
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }
                .padding(24)
            }
            .background(Color.xuanApricotBg)
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 用户协议页面
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("最后更新日期：2026年6月17日")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    PrivacySection(title: "一、服务说明") {
                        PrivacyItem("绪安（ChillCat）是一款 AI 情绪陪伴应用，提供以下服务：")
                        BulletList([
                            "情绪记录与 AI 共情回应",
                            "情绪解码与趋势分析",
                            "稳情计划练习指导",
                            "匿名社区共鸣与鼓励",
                        ])
                        PrivacyItem("本应用不提供医疗诊断、心理治疗或危机干预服务。如有严重心理困扰，请寻求专业帮助。")
                    }
                    
                    PrivacySection(title: "二、用户义务") {
                        BulletList([
                            "提供真实、准确的注册信息",
                            "不得发布违法、暴力、色情或仇恨言论",
                            "不得利用本平台骚扰、欺凌其他用户",
                            "不得利用 AI 服务生成违法内容",
                            "不得进行任何危害平台安全的行为",
                        ])
                    }
                    
                    PrivacySection(title: "三、知识产权") {
                        BulletList([
                            "绪安的品牌标识、设计、代码归本公司所有",
                            "用户在共鸣墙发布的内容，授予平台非独占使用权",
                            "用户个人日记内容的所有权归用户本人所有",
                        ])
                    }
                    
                    PrivacySection(title: "四、免责声明") {
                        BulletList([
                            "AI 回应由算法生成，不构成专业建议",
                            "平台不对用户间互动产生的纠纷承担责任",
                            "因不可抗力导致的服务中断，平台不承担责任",
                            "用户因使用本应用产生的任何损失，平台责任限于法律允许的最低范围",
                        ])
                    }
                    
                    PrivacySection(title: "五、服务变更与终止") {
                        BulletList([
                            "平台有权根据运营需要调整服务内容",
                            "重大变更将提前 7 天通过 App 内通知",
                            "用户可随时停止使用并注销账户",
                            "违反用户协议可能导致账户被暂停或终止",
                        ])
                    }
                    
                    PrivacySection(title: "六、争议解决") {
                        BulletList([
                            "本协议适用中华人民共和国法律",
                            "争议应优先通过友好协商解决",
                            "协商不成的，提交公司所在地有管辖权的人民法院",
                        ])
                    }
                }
                .padding(24)
            }
            .background(Color.xuanApricotBg)
            .navigationTitle("用户协议")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 隐私政策引导页（首次启动展示）
struct PrivacyConsentView: View {
    @Binding var isPresented: Bool
    @State private var isAgreed = false
    @State private var showPrivacy = false
    @State private var showAgreement = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Image("home_ai")
                .font(.system(size: 60))
                .foregroundColor(Color.xuanApricot)
            
            Text("绪安 ChillCat")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
            
            Text("接住所有情绪，温柔自愈，自在松弛")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // 协议确认区
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        isAgreed.toggle()
                    } label: {
                        CCIconMapper.image(for: isAgreed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(isAgreed ? Color.xuanApricot : Color.xuanTextTertiary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("我已阅读并同意")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanTextSecondary)
                        
                        HStack(spacing: 4) {
                            Button("《隐私政策》") {
                                showPrivacy = true
                            }
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanApricot)
                            
                            Text("和")
                                .font(XuanFont.bodyL)
                                .foregroundColor(Color.xuanTextSecondary)
                            
                            Button("《用户协议》") {
                                showAgreement = true
                            }
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanApricot)
                        }
                    }
                }
                
                Button {
                    isPresented = false
                    UserDefaults.standard.set(true, forKey: "privacy_consent_accepted")
                } label: {
                    Text("同意并继续")
                        .font(XuanFont.h3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isAgreed ? Color.xuanApricot : Color.xuanTextTertiary)
                        .cornerRadius(XuanRadius.md)
                }
                .disabled(!isAgreed)
            }
            .padding(24)
            .background(Color.xuanSurface)
            .cornerRadius(XuanRadius.lg)
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 40)
        .background(Color.xuanApricotBg)
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showAgreement) {
            UserAgreementView()
        }
    }
}

// MARK: - 辅助组件

private struct PrivacySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            content()
        }
        .padding(.bottom, 8)
    }
}

private struct PrivacyItem: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(XuanFont.bodyL)
            .foregroundColor(Color.xuanTextSecondary)
            .lineSpacing(4)
    }
}

private struct BulletList: View {
    let items: [String]
    
    init(_ items: [String]) {
        self.items = items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(Color.xuanApricot)
                    Text(item)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
        .padding(.leading, 4)
    }
}

private struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            CCIconMapper.image(for: icon)
                .foregroundColor(Color.xuanApricot)
                .frame(width: 20)
            Text(text)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
        }
    }
}

private struct CrisisHotlineRow: View {
    let name: String
    let number: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
            Spacer()
            Button(number) {
                if let url = URL(string: "tel://\(number.replacingOccurrences(of: "-", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }
            .font(XuanFont.bodyS.monospacedDigit())
            .foregroundColor(Color.xuanApricot)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview("隐私政策") {
    PrivacyPolicyView()
}

#Preview("用户协议") {
    UserAgreementView()
}

#Preview("隐私同意") {
    PrivacyConsentView(isPresented: .constant(true))
}
