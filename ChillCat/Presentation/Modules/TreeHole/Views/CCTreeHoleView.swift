import SwiftUI

struct CCTreeHoleView: View {
    @State private var viewModel = CCTreeHoleViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 头部
            HStack {
                Text("树洞").font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: { viewModel.toggleAnonymous() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isAnonymous ? "theatermasks.fill" : "person.fill")
                        Text(viewModel.isAnonymous ? "匿名" : "实名").font(.system(size: 13))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(viewModel.isAnonymous ? Color(hex: "D4C8E8").opacity(0.3) : Color(hex: "66BB6A").opacity(0.2))
                    .cornerRadius(8)
                }
                .foregroundColor(viewModel.isAnonymous ? Color(hex: "5A7A8A") : Color(hex: "66BB6A"))
            }
            .padding()

            // 发布框
            VStack(spacing: 12) {
                TextField("随便说什么都好，这里不评判…", text: $viewModel.newPostText, axis: .vertical)
                    .focused($isFocused).font(.system(size: 15)).lineLimit(3...6).padding()
                    .background(Color(hex: "F0EDE8")).cornerRadius(12)

                if !viewModel.newPostText.isEmpty {
                    HStack {
                        Picker("可见范围", selection: $viewModel.selectedScope) {
                            ForEach(CCPostScope.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }.pickerStyle(.segmented)
                        Spacer()
                        Button(action: { CCHaptic.medium(); viewModel.publishPost(); isFocused = false }) {
                            Image(systemName: "paperplane.fill").font(.system(size: 18))
                                .foregroundColor(.white).padding(10)
                                .background(Color(hex: "5A7A8A")).clipShape(Circle())
                        }
                    }
                }
            }.padding(.horizontal).padding(.bottom, 8)

            // 帖子列表
            List(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "person.circle.fill").font(.system(size: 20)).foregroundColor(Color(hex: "B8D4E3"))
                        Text(post.displayName).font(.system(size: 14, weight: .medium))
                        Text(post.timeAgo).font(.system(size: 12)).foregroundColor(.secondary)
                        Spacer()
                        Button(action: {}) {
                            HStack(spacing: 2) {
                                Image(systemName: "heart.fill").font(.system(size: 12))
                                Text("\(post.hugs)").font(.system(size: 12))
                            }.foregroundColor(Color(hex: "E8B8C8"))
                        }
                    }
                    Button(action: { coordinator.navigate(to: .postDetail(post)) }) {
                    Text(post.content).font(.system(size: 15)).lineSpacing(4).foregroundColor(theme.textPrimary).multilineTextAlignment(.leading)
                }
                    HStack {
                        Label(post.scope.rawValue, systemImage: post.scope == .public ? "globe.asia.australia" : "hand.raised.fill")
                            .font(.system(size: 11)).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .background(Color(hex: "F9F6F2"))
    }
}
