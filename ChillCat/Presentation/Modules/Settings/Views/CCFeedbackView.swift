import SwiftUI
struct CCFeedbackView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var type = "建议"
    @State private var content = ""
    @State private var contact = ""
    @State private var submitted = false
    let types = ["建议","Bug反馈","其他"]

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                if submitted {
                    VStack(spacing: theme.spacingMD) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size:64)).foregroundColor(Color(hex:"66BB6A"))
                        Text("感谢反馈！").font(.system(size:22,weight:.bold))
                        Text("我们会认真阅读每一条意见").foregroundColor(theme.textSecondary)
                    }.padding(.top,80)
                } else {
                    VStack(alignment:.leading,spacing:theme.spacingSM) {
                        Text("反馈类型").font(.system(size:15,weight:.medium))
                        Picker("", selection: $type) { ForEach(types,id:\.self){Text($0).tag($0)} }.pickerStyle(.segmented)
                    }
                    VStack(alignment:.leading,spacing:theme.spacingSM) {
                        Text("详细描述").font(.system(size:15,weight:.medium))
                        TextEditor(text: $content).frame(minHeight:120).padding(8).background(theme.cardBackground).cornerRadius(theme.radiusMD).overlay(RoundedRectangle(cornerRadius:theme.radiusMD).stroke(Color.gray.opacity(0.2)))
                    }
                    VStack(alignment:.leading,spacing:theme.spacingSM) {
                        Text("联系方式（选填）").font(.system(size:15,weight:.medium))
                        TextField("邮箱或手机号", text: $contact).textFieldStyle(.roundedBorder)
                    }
                    Button(action: { withAnimation { submitted = true } }) {
                        Text("提交反馈").fontWeight(.medium).foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14).background(content.isEmpty ? Color.gray : Color(hex:"5A7A8A")).cornerRadius(theme.radiusMD)
                    }.disabled(content.isEmpty)
                }
            }.padding()
        }.background(theme.background).navigationTitle("意见反馈")
    }
}
