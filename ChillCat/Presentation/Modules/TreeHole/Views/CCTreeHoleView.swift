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
        .background(Color.xuanApricotBg)
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
            Text("树洞")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)
            Spacer()

            // 在线人数
            HStack(spacing: 4) {
                Text("🕊️").font(.system(size: 14))
                Text("\(viewModel.onlineCount) 人此刻")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(.horizontal, XuanSpacing.sm)
            .padding(.vertical, 4)
            .background(Color(hex: "F2DBC9"))
            .cornerRadius(XuanRadius.sm)
        }
        .padding(.horizontal)
        .padding(.top, XuanSpacing.sm)
        .padding(.bottom, XuanSpacing.xs)
    }

    // MARK: - Publish Box (对照截图: 输入框 + "发送倾诉"大按钮)
    private var publishBox: some View {
        VStack(spacing: XuanSpacing.md) {
            // 输入框
            ZStack(alignment: .topLeading) {
                if viewModel.newPostText.isEmpty && !isFocused {
                    Text("随便说什么都好，这里不评判…")
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextTertiary)
                        .padding(.horizontal, XuanSpacing.lg)
                        .padding(.vertical, XuanSpacing.lg)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $viewModel.newPostText)
                    .focused($isFocused)
                    .font(XuanFont.bodyL)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(XuanSpacing.md)
            }
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()

            // 操作栏 + 发送按钮
            if !viewModel.newPostText.isEmpty {
                HStack {
                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(Color.xuanTextSecondary)
                            .frame(width: 40, height: 40)
                    }

                    Spacer()

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
                        HStack(spacing: XuanSpacing.sm) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14))
                            Text("发送倾诉")
                                .font(XuanFont.bodyLMedium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, XuanSpacing.xl)
                        .padding(.vertical, 12)
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.full)
                        .xuanCardShadow()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, XuanSpacing.sm)
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
                            .foregroundColor(Color.xuanTextSecondary)
                        Text(post.timeAgo)
                            .font(.system(size: 12))
                            .foregroundColor(Color.xuanTextSecondary)
                        Spacer()
                    }

                    // Content
                    Text(post.content)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .foregroundColor(Color.xuanTextPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)

                    // Bottom: resonance count + actions
                    HStack(spacing: 12) {
                        // Resonance count
                        HStack(spacing: 4) {
                            Image(systemName: post.hasResonated ? "heart.fill" : "heart")
                                .font(.system(size: 13))
                                .foregroundColor(post.hasResonated ? Color.xuanDanger : Color.xuanPink)
                            Text("\(post.formattedResonance) 人共鸣")
                                .font(.system(size: 13))
                                .foregroundColor(Color.xuanTextSecondary)
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
                                .foregroundColor(Color.xuanApricot)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "F2DBC9"))
                                .cornerRadius(XuanRadius.sm)
                        }

                        // Share resonance - just resonate directly
                        Button(action: {
                            CCHaptic.medium()
                            viewModel.resonatePost(post)
                        }) {
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.xuanTextSecondary)
                                .padding(8)
                                .background(Color.xuanSurface)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 12)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Resonate Sheet

    private var resonateSheetView: some View {
        VStack(spacing: 16) {
            Text("我也有过这种感觉")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.xuanTextPrimary)

            // Warm template chips
            warmTemplateChips

            TextField("说一句鼓励的话吧（可选）", text: $resonateMessage, axis: .vertical)
                .font(.system(size: 15))
                .padding()
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)
                .lineLimit(2...4)

            HStack(spacing: 12) {
                Button("取消") {
                    showResonateSheet = false
                }
                .foregroundColor(Color.xuanTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)

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
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
            }
        }
        .padding()
        .background(Color.xuanApricotBg)
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
                                        : Color.xuanTextSecondary
                                )
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            resonateMessage == template.content
                                ? Color.xuanApricot
                                : Color.xuanSurface
                        )
                        .cornerRadius(XuanRadius.full)
                        .overlay(
                            RoundedRectangle(cornerRadius: XuanRadius.full)
                                .stroke(Color.xuanApricot.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Guideline Banner

    private var guidelineBanner: some View {
        HStack(spacing: XuanSpacing.sm) {
            Text("💚")
                .font(.system(size: 14))
            Text("社区准则：温暖友善，互相支持")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showGuidelineBanner = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.vertical, XuanSpacing.sm)
        .background(Color.xuanMint.opacity(0.15))
    }

    // MARK: - Helpers

    private func emotionColorFor(_ colorName: String) -> Color {
        switch colorName {
        case "softGreen": return Color.xuanMint
        case "warmLight": return Color.xuanApricotDark
        case "primaryMuted": return Color.xuanApricot.opacity(0.6)
        case "softPurple": return Color(hex: "A085C6")
        case "softPink": return Color.xuanPink
        case "primaryLight": return Color.xuanApricotLight
        case "error": return Color.xuanDanger
        case "softPurpleLight": return Color(hex: "A085C6").opacity(0.3)
        case "warm": return Color.xuanApricotDark
        default: return Color.xuanApricot
        }
    }
}
