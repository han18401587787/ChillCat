import SwiftUI
struct CCFeedbackView: View {
    @State private var viewModel = CCSettingsViewModel()
    let types = ["建议","Bug反馈","其他"]

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.lg) {
                if viewModel.submitted {
                    VStack(spacing: XuanSpacing.md) {
                        Image("home_checkin").font(.system(size:64)).foregroundColor(Color.xuanMint)
                        Text("感谢反馈！").font(.system(size:22,weight:.bold))
                        Text("我们会认真阅读每一条意见").foregroundColor(Color.xuanTextSecondary)
                    }.padding(.top,80)
                } else {
                    VStack(alignment:.leading,spacing:XuanSpacing.sm) {
                        Text("反馈类型").font(.system(size:15,weight:.medium))
                        Picker("", selection: $viewModel.feedbackType) { ForEach(types,id:\.self){Text($0).tag($0)} }.pickerStyle(.segmented).accessibilityIdentifier("feedback_type_picker")
                    }
                    VStack(alignment:.leading,spacing:XuanSpacing.sm) {
                        Text("详细描述").font(.system(size:15,weight:.medium))
                        TextEditor(text: $viewModel.feedbackContent).frame(minHeight:120).padding(8).background(Color.xuanWhite).cornerRadius(XuanRadius.md).overlay(RoundedRectangle(cornerRadius:XuanRadius.md).stroke(Color.gray.opacity(0.2))).accessibilityIdentifier("feedback_content")
                    }
                    VStack(alignment:.leading,spacing:XuanSpacing.sm) {
                        Text("联系方式（选填）").font(.system(size:15,weight:.medium))
                        TextField("邮箱或手机号", text: $viewModel.feedbackContact).textFieldStyle(.roundedBorder).accessibilityIdentifier("feedback_contact")
                    }
                    Button(action: { Task { await viewModel.submitFeedback() } }) {
                        if viewModel.isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("提交反馈").fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14)
                    .background(viewModel.feedbackContent.isEmpty || viewModel.isSubmitting ? Color.gray : Color.xuanApricotDark)
                    .cornerRadius(XuanRadius.md)
                    .disabled(viewModel.feedbackContent.isEmpty || viewModel.isSubmitting)
                    .accessibilityIdentifier("feedback_submit")
                }
            }.padding()
        }
        .background(Color.xuanApricotBg).navigationTitle("意见反馈")
        .alert("提交失败", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("确定", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
