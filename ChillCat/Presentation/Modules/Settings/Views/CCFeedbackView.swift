import SwiftUI
struct CCFeedbackView: View {
    @State private var viewModel = CCSettingsViewModel()
    let types = ["建议","Bug反馈","其他"]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                if viewModel.submitted {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size:64)).foregroundColor(AppTheme.accentMint)
                        Text("感谢反馈！").font(.system(size:22,weight:.bold))
                        Text("我们会认真阅读每一条意见").foregroundColor(AppTheme.textSecondary)
                    }.padding(.top,80)
                } else {
                    VStack(alignment:.leading,spacing:AppSpacing.sm) {
                        Text("反馈类型").font(.system(size:15,weight:.medium))
                        Picker("", selection: $viewModel.feedbackType) { ForEach(types,id:\.self){Text($0).tag($0)} }.pickerStyle(.segmented)
                    }
                    VStack(alignment:.leading,spacing:AppSpacing.sm) {
                        Text("详细描述").font(.system(size:15,weight:.medium))
                        TextEditor(text: $viewModel.feedbackContent).frame(minHeight:120).padding(8).background(AppTheme.cardBackground).cornerRadius(AppRadius.md).overlay(RoundedRectangle(cornerRadius:AppRadius.md).stroke(Color.gray.opacity(0.2)))
                    }
                    VStack(alignment:.leading,spacing:AppSpacing.sm) {
                        Text("联系方式（选填）").font(.system(size:15,weight:.medium))
                        TextField("邮箱或手机号", text: $viewModel.feedbackContact).textFieldStyle(.roundedBorder)
                    }
                    Button(action: { Task { await viewModel.submitFeedback() } }) {
                        if viewModel.isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("提交反馈").fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.white).frame(maxWidth:.infinity).padding(.vertical,14)
                    .background(viewModel.feedbackContent.isEmpty || viewModel.isSubmitting ? Color.gray : AppTheme.primaryDark)
                    .cornerRadius(AppRadius.md)
                    .disabled(viewModel.feedbackContent.isEmpty || viewModel.isSubmitting)
                }
            }.padding()
        }
        .background(AppTheme.background).navigationTitle("意见反馈")
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
