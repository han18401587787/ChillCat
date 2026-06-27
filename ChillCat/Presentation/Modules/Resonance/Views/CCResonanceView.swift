//
//  CCResonanceView.swift
//  绪安 - 共鸣墙 (Ardot v3)
//
//  对照设计图像素级还原
//  包含：共鸣故事卡片列表、情绪色条、互动按钮、悬浮发布按钮

import SwiftUI

struct CCResonanceView: View {
    @State private var viewModel = CCResonanceViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

    @State private var showComposer = false
    @State private var composerText = ""
    @State private var showComposerEmoji = false
    @FocusState private var composerFocused: Bool

    @State private var resonateTarget: CCResonanceDisplayItem?
    @State private var resonateMessage = ""
    @State private var showResonateEmoji = false

    @State private var shareItem: CCResonanceDisplayItem?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppTheme.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.resonanceItems.isEmpty {
                CCLoadingView(message: "正在连接共鸣…")
            } else if let error = viewModel.error, viewModel.resonanceItems.isEmpty {
                CCErrorView(error: error) { await viewModel.loadResonance() }
            } else if viewModel.resonanceItems.isEmpty {
                CCEmptyStateView(
                    title: "还没有共鸣",
                    message: "成为第一个分享感受的人吧",
                    imageName: "heart.text.square",
                    actionTitle: "写下心情",
                    action: { showComposer = true }
                )
            } else {
                resonanceList
            }

            if !viewModel.resonanceItems.isEmpty {
                composeFAB
            }
        }
        .navigationTitle("共鸣墙")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .task { await viewModel.loadResonance() }
        .sheet(isPresented: $showComposer) { composeSheet }
        .sheet(item: $resonateTarget) { item in
            resonateSheet(for: item)
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.content])
                .presentationDetents([.medium])
        }
        .cc_emojiPickerOverlay(isShowing: $showComposerEmoji) { emoji in
            composerText += emoji.displayName
        }
        .cc_emojiPickerOverlay(isShowing: $showResonateEmoji) { emoji in
            resonateMessage += emoji.displayName
        }
        .animation(.easeInOut(duration: 0.25), value: showComposerEmoji)
        .animation(.easeInOut(duration: 0.25), value: showResonateEmoji)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: AppSpacing.sm) {
                // 在线人数
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.accentMint)
                    Text("\(viewModel.onlineCount) 人此刻")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 4)
                .background(AppTheme.accentMint.opacity(0.1))
                .cornerRadius(AppRadius.full)

                // 鼓励链入口
                Button(action: {
                    coordinator.navigate(to: .encourageChain)
                }) {
                    HStack(spacing: 2) {
                        Text("🔥").font(.system(size: 12))
                        Text("鼓励链").font(AppFont.footnote)
                    }
                    .foregroundColor(AppTheme.warmGold)
                }
            }
        }
    }

    // MARK: - List
    private var resonanceList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.resonanceItems) { item in
                    resonanceCard(item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            coordinator.navigate(to: .resonanceDetail(item))
                        }
                        .onAppear {
                            if item.id == viewModel.resonanceItems.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    HStack { Spacer(); ProgressView(); Spacer() }.padding()
                }

                if !viewModel.hasMore && !viewModel.resonanceItems.isEmpty {
                    Text("— 已经到底了 —")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.vertical, AppSpacing.lg)
                }
            }
            .padding(AppSpacing.lg)
            .padding(.bottom, 80)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Card
    private func resonanceCard(_ item: CCResonanceDisplayItem) -> some View {
        HStack(spacing: 0) {
            // 情绪色条
            RoundedRectangle(cornerRadius: 2)
                .fill(item.emotionColorValue)
                .frame(width: 4)
                .padding(.vertical, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // 顶栏：情绪标签 + 时间
                HStack(spacing: AppSpacing.sm) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.emotionColorValue)
                            .frame(width: 8, height: 8)
                        Text(item.emotion)
                            .font(AppFont.footnote)
                            .foregroundColor(item.emotionColorValue)
                    }
                    Spacer()
                    Text(item.timeAgo)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }

                // 内容
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // 底栏：共鸣数 + 操作
                HStack(spacing: AppSpacing.lg) {
                    Button(action: {
                        CCHaptic.light()
                        resonateTarget = item
                        resonateMessage = ""
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.warmPink)
                            Text("\(item.resonanceCount) 人共鸣")
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: { showComposer = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 12))
                            Text("我也想说")
                                .font(AppFont.caption2)
                        }
                        .foregroundColor(AppTheme.info)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        CCHaptic.light()
                        shareItem = item
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12))
                            Text("分享")
                                .font(AppFont.caption2)
                        }
                        .foregroundColor(AppTheme.info)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, AppSpacing.sm)
            .padding(.vertical, AppSpacing.md)
            .padding(.trailing, AppSpacing.md)
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color(hex: "2C2416").opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Floating Compose Button
    private var composeFAB: some View {
        Button(action: { showComposer = true }) {
            HStack(spacing: 6) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 16))
                Text("写下心情")
                    .font(AppFont.bodyBold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppRadius.full)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 3)
        }
        .padding(.trailing, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
    }

    // MARK: - Compose Sheet
    private var composeSheet: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Spacer()
                    Button(action: { showComposerEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.trailing, 8)

                    Button(action: {
                        guard !composerText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        viewModel.newPostText = composerText
                        viewModel.publishPost()
                        composerText = ""
                        showComposer = false
                        CCHaptic.medium()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                composerText.trimmingCharacters(in: .whitespaces).count >= 3
                                    ? AppTheme.primary : AppTheme.textMuted
                            )
                            .clipShape(Circle())
                    }
                    .disabled(composerText.trimmingCharacters(in: .whitespaces).count < 3)
                }

                TextField("分享你的心情，与千万人共鸣…", text: $composerText, axis: .vertical)
                    .focused($composerFocused)
                    .font(AppFont.body)
                    .lineLimit(4...10)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)

                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.background)
            .navigationTitle("写下心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        composerText = ""
                        showComposer = false
                    }
                }
            }
        }
    }

    // MARK: - Resonate Sheet
    private func resonateSheet(for item: CCResonanceDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: 6) {
                    Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                    Text(item.emotion)
                        .font(AppFont.footnote)
                        .foregroundColor(item.emotionColorValue)
                    Text("·").foregroundColor(AppTheme.textMuted)
                    Text(item.timeAgo)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textMuted)
                }
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(5)
                    .lineLimit(3)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.surface)
            .cornerRadius(AppRadius.md)

            Text("我也有过这种感觉")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            Text("你愿意附上一句鼓励吗？（选填）")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)

            HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                TextField("一句温暖的话…", text: $resonateMessage, axis: .vertical)
                    .font(AppFont.body)
                    .lineLimit(2...4)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)

                Button(action: { showResonateEmoji.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primary)
                }
                .padding(.bottom, 8)
            }

            Button(action: {
                CCHaptic.success()
                let msg = resonateMessage.trimmingCharacters(in: .whitespaces)
                viewModel.hugResonance(item, message: msg.isEmpty ? nil : msg)
                resonateTarget = nil
                resonateMessage = ""
            }) {
                HStack {
                    Spacer()
                    Text("💚 表达共鸣")
                        .font(AppFont.buttonLabel)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(AppTheme.accentMint)
                .cornerRadius(AppRadius.md)
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.background)
    }
}

// MARK: - Share Sheet
private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
