import SwiftUI
struct CCTreeHolePostDetailView: View {
    let post: CCTreeHolePost
    @Environment(\.ccAppTheme) private var theme
    @State private var hugs: Int
    @State private var didHug = false

    init(post: CCTreeHolePost) { self.post = post; _hugs = State(initialValue: post.hugs) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                HStack {
                    Image(systemName: "person.circle.fill").font(.system(size: 24)).foregroundColor(Color(hex:"B8D4E3"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.displayName).font(.system(size:15,weight:.medium))
                        Text(post.timeAgo).font(.system(size:12)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                    Text(post.scope.rawValue).font(.system(size:11)).foregroundColor(.secondary).padding(.horizontal,8).padding(.vertical,2).background(theme.surface).cornerRadius(4)
                }
                Text(post.content).font(.system(size:16)).lineSpacing(6).padding(.vertical, theme.spacingSM)
                Divider()
                Button(action: { hugs += 1; CCHaptic.medium(); didHug = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: didHug ? "heart.fill" : "heart").foregroundColor(didHug ? Color(hex:"E57373") : theme.textMuted)
                        Text("\(hugs) 抱抱").font(.system(size:14)).foregroundColor(theme.textSecondary)
                    }.padding(.vertical,8)
                }
                Text("树洞没有评判，只有温柔回应。").font(.system(size:13)).foregroundColor(theme.textMuted).padding(.top,theme.spacingSM)
            }.padding()
        }.background(theme.background).navigationTitle("帖子详情")
    }
}
