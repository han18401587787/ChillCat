import SwiftUI

struct CCTreeHoleView: View {
    @State private var viewModel = CCTreeHoleViewModel()
    @State private var showEmoji = false
    @State private var showResonateSheet = false
    @State private var resonateTarget: CCResonancePost?
    @State private var resonateMessage = ""
    @State private var showContentWarning = false
    @State private var pendingPublishText: String = ""
    @State private var showGuidelineBanner = true
    @Environment(CCAppCoordinator.self) private var coordinator
        @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Community guideline banner
            if showGuidelineBanner {
                guidelineBanner
            }

            // Header
            headerSection

            // Publish box
            publishBox

            // Post list
            if viewModel.isLoading && viewModel.posts.isEmpty {
                Spacer()
                CCLoadingView(message: "正在连接共鸣墙…")
                Spacer()
            } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
                Spacer()
                CCEmptyStateView(
                    title: "加载失败",
                    message: error,
                    imageName: "wifi.slash"
                )
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
        .background(AppTheme.background)
        .overlay(alignment: .bottom) {
            if showEmoji {
                CCEmojiPicker(isShowing: $showEmoji) { emoji in
                    viewModel.newPostText += emoji.displayName
                }
                .frame(height: 300)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showEmoji)
        .sheet(isPresented: $showResonateSheet) {
            resonateSheetView
                .presentationDetents([.height(400)])
        }
        .alert("社区准则提醒", isPresented: $showContentWarning) {
            Button("修改") {
                viewModel.newPostText = pendingPublishText
                pendingPublishText = ""
                isFocused = true
            }
            Button("仍然发布", role: .destructive) {
                viewModel.newPostText = pendingPublishText
                pendingPublishText = ""
                viewModel.publishPost(force: true)
                isFocused = false
            }
        } message: {
            Text("你的文字会被很多人看到，确保内容温暖友善。确定要发布吗？")
        }
        .task { await viewModel.loadPosts() }
        .task { await viewModel.loadWarmTemplates() }
        .onReceive(NotificationCenter.default.publisher(for: .treeHoleDidUpdate)) { _ in
            Task { await viewModel.refresh() }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("共鸣墙")
                .font(AppFont.title1)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()

            // Mutual aid group entry
            NavigationLink(value: CCAppRoute.mutualAidGroups) {
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 12))
                    Text("互助小组")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.accentMint)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 4)
                .background(AppTheme.accentMint.opacity(0.12))
                .cornerRadius(AppRadius.sm)
            }

            HStack(spacing: 4) {
                Text("🕊️").font(.system(size: 14))
                Text("\(viewModel.onlineCount) 人此刻")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 4)
            .background(AppTheme.primary.opacity(0.1))
            .cornerRadius(AppRadius.sm)

            NavigationLink(value: CCAppRoute.encourageChain) {
                HStack(spacing: 4) {
                    Text("🔥").font(.system(size: 13))
                    Text("鼓励链")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.warmGold)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 4)
                .background(AppTheme.warmGold.opacity(0.12))
                .cornerRadius(AppRadius.sm)
            }
        }
        .padding(.horizontal)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
    }

    // MARK: - Publish Box

    private var publishBox: some View {
        VStack(spacing: 12) {
            TextField("随便说什么都好，这里不评判…", text: $viewModel.newPostText, axis: .vertical)
                .focused($isFocused)
                .font(.system(size: 15))
                .lineLimit(3...6)
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.md)

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
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.trailing, 8)

                    Button(action: {
                        CCHaptic.medium()
                        if viewModel.checkContentBeforePublish(viewModel.newPostText) {
                            viewModel.publishPost()
                            isFocused = false
                        } else {
                            pendingPublishText = viewModel.newPostText
                            viewModel.newPostText = ""
                            showContentWarning = true
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(AppTheme.primary)
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
                            .foregroundColor(AppTheme.textSecondary)
                        Text(post.timeAgo)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }

                    // Content
                    Text(post.content)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)

                    // Bottom: resonance count + actions
                    HStack(spacing: 12) {
                        // Resonance count
                        HStack(spacing: 4) {
                            Image(systemName: post.hasResonated ? "heart.fill" : "heart")
                                .font(.system(size: 13))
                                .foregroundColor(post.hasResonated ? AppTheme.crisisRed : AppTheme.warmPink)
                            Text("\(post.formattedResonance) 人共鸣")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
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
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.primary.opacity(0.1))
                                .cornerRadius(AppRadius.sm)
                        }

                        // Share resonance - just resonate directly
                        Button(action: {
                            CCHaptic.medium()
                            viewModel.resonatePost(post)
                        }) {
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(8)
                                .background(AppTheme.surface)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 12)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resonate Sheet

    private var resonateSheetView: some View {
        VStack(spacing: 16) {
            Text("我也有过这种感觉")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            // Warm template chips
            warmTemplateChips

            TextField("说一句鼓励的话吧（可选）", text: $resonateMessage, axis: .vertical)
                .font(.system(size: 15))
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.md)
                .lineLimit(2...4)

            HStack(spacing: 12) {
                Button("取消") {
                    showResonateSheet = false
                }
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.md)

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
                        .background(AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }
            }
        }
        .padding()
        .background(AppTheme.background)
    }

    // MARK: - Warm Template Chips

    private var warmTemplateChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.warmTemplates) { template in
                    Button(action: {
                        CCHaptic.light()
                        resonateMessage = template.content
                    }) {
                        HStack(spacing: 4) {
                            Text(template.emoji)
                                .font(.system(size: 12))
                            Text(template.content)
                                .font(.system(size: 12))
                                .foregroundColor(
                                    resonateMessage == template.content
                                        ? .white
                                        : AppTheme.textSecondary
                                )
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            resonateMessage == template.content
                                ? AppTheme.primary
                                : AppTheme.surface
                        )
                        .cornerRadius(AppRadius.full)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.full)
                                .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Guideline Banner

    private var guidelineBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("💚")
                .font(.system(size: 14))
            Text("社区准则：温暖友善，互相支持")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showGuidelineBanner = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(AppTheme.accentMint.opacity(0.15))
    }

    // MARK: - Helpers

    private func emotionColorFor(_ colorName: String) -> Color {
        switch colorName {
        case "softGreen": return AppTheme.accentMint
        case "warmLight": return AppTheme.warmGold
        case "primaryMuted": return AppTheme.primaryMuted
        case "softPurple": return AppTheme.warmPurple
        case "softPink": return AppTheme.warmPink
        case "primaryLight": return AppTheme.primaryLight
        case "error": return AppTheme.error
        case "softPurpleLight": return AppTheme.warmPurple.opacity(0.3)
        case "warm": return AppTheme.warmGold
        default: return AppTheme.primary
        }
    }
}
