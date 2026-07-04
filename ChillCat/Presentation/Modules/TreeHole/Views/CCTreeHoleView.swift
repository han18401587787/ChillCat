//
//  CCTreeHoleView.swift
//  绪安 - 树洞 (严格对照设计稿 page_19 像素级还原)
//
//  设计稿来源: /workspace/design_pages/page_19.png
//  布局：标题"树洞" + 在线人数 → 输入框 → 发送倾诉大按钮 → 倾诉列表

import SwiftUI

struct CCTreeHoleView: View {
    @State var viewModel: CCTreeHoleViewModel
    @State private var showEmoji = false
    @State private var showContentWarning = false
    @State private var pendingPublishText: String = ""
    @State private var showGuidelineBanner = true
    @State private var treeHoleHeartScale: [String: CGFloat] = [:]
    @State private var treeHoleHeartTrigger: [String: Bool] = [:]
    @Environment(CCAppCoordinator.self) private var coordinator
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 社区准则横幅
            if showGuidelineBanner {
                guidelineBanner
            }

            // 标题
            headerSection

            // 发布框
            publishBox

            // 倾诉列表
            postListView
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

            // 在线人数标签
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.xuanMint)
                    .frame(width: 6, height: 6)
                Text("\(viewModel.onlineCount) 人在倾诉")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .padding(.horizontal, XuanSpacing.sm)
            .padding(.vertical, 4)
            .background(Color.xuanMint.opacity(0.1))
            .cornerRadius(XuanRadius.full)
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.top, XuanSpacing.sm)
        .padding(.bottom, XuanSpacing.xs)
    }

    // MARK: - 发布框 (严格对照设计稿)
    private var publishBox: some View {
        VStack(spacing: XuanSpacing.md) {
            // 输入框
            ZStack(alignment: .topLeading) {
                if viewModel.newPostText.isEmpty && !isFocused {
                    Text("随便说什么都好，这里不评判…")
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextTertiary)
                        .padding(.horizontal, XuanSpacing.lg)
                        .padding(.vertical, XuanSpacing.md)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $viewModel.newPostText)
                    .focused($isFocused)
                    .font(XuanFont.bodyL)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(XuanSpacing.sm)
            }
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.lg)
            .xuanCardShadow()

            // 发送倾诉按钮 (总是显示，但内容为空时半透明禁用)
            Button(action: {
                guard !viewModel.newPostText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    viewModel.newPostText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.xuanApricot.opacity(0.4)
                        : Color.xuanApricot
                )
                .cornerRadius(XuanRadius.md)
            }
            .disabled(viewModel.newPostText.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityIdentifier("treehole_publish_button")

            // 快捷模板
            warmTemplateChips
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.bottom, XuanSpacing.sm)
    }

    // MARK: - 倾诉列表
    private var postListView: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                Spacer()
                CCLoadingView(message: "正在加载倾诉…")
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
                    title: "树洞是空的",
                    message: "成为第一个倾诉的人吧",
                    imageName: "bubble.left.and.bubble.right"
                )
                Spacer()
            } else {
                List(viewModel.posts) { post in
                    treeHoleCard(post)
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
    }

    // MARK: - 树洞卡片 (设计稿样式)
    private func treeHoleCard(_ post: CCResonancePost) -> some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(emotionColorFor(post.emotionColor))
                        .frame(width: 8, height: 8)
                    Text(post.emotion)
                        .font(XuanFont.bodyS)
                        .foregroundColor(emotionColorFor(post.emotionColor))
                }

                Spacer()

                Text(post.timeAgo)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(Color.xuanTextPrimary)
                .lineSpacing(5)
                .lineLimit(5)

            // 共鸣按钮
            HStack {
                Button(action: {
                    CCHaptic.light()
                    viewModel.resonatePost(post)
                    // 放大动画
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        treeHoleHeartScale[post.id] = 1.4
                    }
                    // 0.3s 后复原
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            treeHoleHeartScale[post.id] = 1.0
                        }
                    }
                    // Lottie 动画：触发显示 → 0.8s 后隐藏
                    treeHoleHeartTrigger[post.id] = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            treeHoleHeartTrigger[post.id] = false
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        ZStack {
                            if treeHoleHeartTrigger[post.id] == true {
                                CCHeartBeatAnimation(
                                    trigger: Binding(
                                        get: { treeHoleHeartTrigger[post.id] ?? false },
                                        set: { treeHoleHeartTrigger[post.id] = $0 }
                                    ),
                                    size: 26
                                )
                                .allowsHitTesting(false)
                                .transition(.opacity)
                            }
                            Image(systemName: post.hasResonated ? "heart.fill" : "heart")
                                .font(.system(size: 13))
                                .foregroundColor(post.hasResonated ? Color.xuanDanger : Color.xuanPink)
                                .scaleEffect(treeHoleHeartScale[post.id] ?? 1.0)
                                .opacity(treeHoleHeartTrigger[post.id] == true ? 0 : 1)
                        }
                        Text("\(post.resonanceCount) 人共鸣")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("treehole_resonate_\(post.id)")

                Spacer()

                Button(action: {
                    viewModel.newPostText = ""
                    isFocused = true
                }) {
                    Text("我也想说")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanApricot)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.xuanApricotLight)
                        .cornerRadius(XuanRadius.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 快捷模板
    private var warmTemplateChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: XuanSpacing.sm) {
                quickTemplate("💚 今天心情不太好")
                quickTemplate("🌙 最近失眠严重")
                quickTemplate("💔 和重要的人吵架了")
                quickTemplate("😔 工作压力好大")
                quickTemplate("😊 分享一个小确幸")
            }
            .padding(.horizontal, 4)
        }
    }

    private func quickTemplate(_ text: String) -> some View {
        Button(action: {
            CCHaptic.light()
            viewModel.newPostText = text
            isFocused = true
        }) {
            Text(text)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.full)
                .overlay(
                    RoundedRectangle(cornerRadius: XuanRadius.full)
                        .stroke(Color.xuanBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("treehole_quick_template")
    }

    // MARK: - 社区准则横幅
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
                Image("common_close")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.vertical, XuanSpacing.sm)
        .background(Color.xuanMint.opacity(0.12))
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
        default: return Color.xuanApricot
        }
    }
}
