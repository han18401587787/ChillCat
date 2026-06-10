import SwiftUI

struct CCTreeHoleView: View {
    @State private var viewModel = CCTreeHoleViewModel()
    @State private var showEmoji = false
    @State private var showResonateSheet = false
    @State private var resonateTarget: CCResonancePost?
    @State private var resonateMessage = ""
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Publish box
            publishBox

            // Post list
            if viewModel.isLoading && viewModel.posts.isEmpty {
                Spacer()
                CCLoadingView(message: "正在连接共鸣墙…")
                Spacer()
            } else if viewModel.posts.isEmpty {
                Spacer()
                CCEmptyStateView(
                    title: "还没有共鸣",
                    message: "成为第一个分享心声的人吧",
                    imageName: "bubble.left.and.bubble.right"
                )
                Spacer()
            } else {
                List(viewModel.posts) { post in
                    resonanceCard(post)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onAppear {
                            if post.id == viewModel.posts.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.refresh() }

                if viewModel.isLoadingMore {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding()
                }
            }
        }
        .background(theme.background)
        .overlay(alignment: .bottom) {
            if showEmoji {
                CCEmojiPicker(isShowing: $showEmoji) { emoji in
                    viewModel.newPostText += emoji
                }
                .frame(height: 300)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showEmoji)
        .sheet(isPresented: $showResonateSheet) {
            resonateSheetView
                .presentationDetents([.height(260)])
        }
        .task { await viewModel.loadPosts() }
        .onReceive(NotificationCenter.default.publisher(for: .treeHoleDidUpdate)) { _ in
            Task { await viewModel.refresh() }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("共鸣墙")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(theme.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                Text("🕊️")
                    .font(.system(size: 14))
                Text("\(viewModel.onlineCount) 人此刻")
                    .font(.system(size: 13))
                    .foregroundColor(theme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(theme.primaryMuted.opacity(0.2))
            .cornerRadius(theme.radiusSM)

            NavigationLink(value: CCAppRoute.encourageChain) {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 13))
                    Text("鼓励链")
                        .font(.system(size: 13))
                        .foregroundColor(theme.warm)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(theme.warm.opacity(0.1))
                .cornerRadius(theme.radiusSM)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Publish Box

    private var publishBox: some View {
        VStack(spacing: 12) {
            TextField("随便说什么都好，这里不评判…", text: $viewModel.newPostText, axis: .vertical)
                .focused($isFocused)
                .font(.system(size: 15))
                .lineLimit(3...6)
                .padding()
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)

            if !viewModel.newPostText.isEmpty {
                HStack {
                    Picker("可见范围", selection: $viewModel.selectedScope) {
                        ForEach(CCPostScope.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)

                    Spacer()

                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(theme.primary)
                    }
                    .padding(.trailing, 8)

                    Button(action: {
                        CCHaptic.medium()
                        viewModel.publishPost()
                        isFocused = false
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(theme.primary)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Resonance Card

    private func resonanceCard(_ post: CCResonancePost) -> some View {
        Button(action: {
            let displayItem = CCResonanceDisplayItem(
                id: post.id, content: post.content, emotion: post.emotion,
                emotionColor: post.emotionColor, isAnonymous: post.isAnonymous,
                displayName: post.displayName,
                resonanceCount: post.resonanceCount, createdAt: post.createdAt
            )
            coordinator.navigate(to: .resonanceDetail(displayItem))
        }) {
            HStack(alignment: .top, spacing: 0) {
                // Left emotion color bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(emotionColorFor(post.emotionColor))
                    .frame(width: 4)
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)

                VStack(alignment: .leading, spacing: 10) {
                    // Top: emotion tag + time
                    HStack(spacing: 6) {
                        Circle()
                            .fill(emotionColorFor(post.emotionColor))
                            .frame(width: 8, height: 8)
                        Text(post.emotion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(emotionColorFor(post.emotionColor))
                        Text("·")
                            .foregroundColor(theme.textMuted)
                        Text(post.timeAgo)
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted)
                        Spacer()
                    }

                    // Content
                    Text(post.content)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .foregroundColor(theme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)

                    // Bottom: resonance count + actions
                    HStack(spacing: 12) {
                        // Resonance count
                        HStack(spacing: 4) {
                            Image(systemName: post.hasResonated ? "heart.fill" : "heart")
                                .font(.system(size: 13))
                                .foregroundColor(post.hasResonated ? theme.error : theme.softPink)
                            Text("\(post.formattedResonance) 人共鸣")
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSecondary)
                        }

                        Spacer()

                        // "我也想说" button
                        Button(action: {
                            resonateTarget = post
                            resonateMessage = ""
                            showResonateSheet = true
                        }) {
                            Text("我也想说")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(theme.primary.opacity(0.1))
                                .cornerRadius(theme.radiusSM)
                        }

                        // Share resonance - just resonate directly
                        Button(action: {
                            CCHaptic.medium()
                            viewModel.resonatePost(post)
                        }) {
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.textSecondary)
                                .padding(8)
                                .background(theme.surface)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 12)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusLG)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resonate Sheet

    private var resonateSheetView: some View {
        VStack(spacing: 16) {
            Text("我也有过这种感觉")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.textPrimary)

            TextField("说一句鼓励的话吧（可选）", text: $resonateMessage, axis: .vertical)
                .font(.system(size: 15))
                .padding()
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)
                .lineLimit(2...4)

            HStack(spacing: 12) {
                Button("取消") {
                    showResonateSheet = false
                }
                .foregroundColor(theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)

                Button(action: {
                    CCHaptic.success()
                    if let post = resonateTarget {
                        viewModel.resonatePost(post, encouragement: resonateMessage.isEmpty ? nil : resonateMessage)
                    }
                    showResonateSheet = false
                }) {
                    Text("发送鼓励")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.primary)
                        .cornerRadius(theme.radiusMD)
                }
            }
        }
        .padding()
        .background(theme.background)
    }

    // MARK: - Helpers

    private func emotionColorFor(_ colorName: String) -> Color {
        switch colorName {
        case "softGreen": return theme.softGreen
        case "warmLight": return theme.warmLight
        case "primaryMuted": return theme.primaryMuted
        case "softPurple": return theme.softPurple
        case "softPink": return theme.softPink
        case "primaryLight": return theme.primaryLight
        case "error": return theme.error
        case "softPurpleLight": return theme.softPurpleLight
        case "warm": return theme.warm
        default: return theme.primaryMuted
        }
    }
}
