//
//  CCResonanceView.swift
//  绪安 - 共鸣墙
//

import SwiftUI

struct CCResonanceView: View {
    @State private var viewModel = CCResonanceViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    // Compose
    @State private var showComposer = false
    @State private var composerText = ""
    @State private var showComposerEmoji = false
    @FocusState private var composerFocused: Bool

    // Resonate sheet
    @State private var resonateTarget: CCResonanceDisplayItem?
    @State private var resonateMessage = ""
    @State private var showResonateEmoji = false

    // Share sheet
    @State private var shareItem: CCResonanceDisplayItem?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            theme.background.ignoresSafeArea()

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

            // Floating compose button
            if !viewModel.resonanceItems.isEmpty {
                composeFAB
            }
        }
        .navigationTitle("共鸣墙")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task { await viewModel.loadResonance() }
        // Compose sheet
        .sheet(isPresented: $showComposer) { composeSheet }
        // Resonate sheet
        .sheet(item: $resonateTarget) { item in
            resonateSheet(for: item)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
        // Share sheet
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.content])
                .presentationDetents([.medium])
        }
        // Emoji overlays
        .overlay(alignment: .bottom) {
            if showComposerEmoji {
                CCEmojiPicker(isShowing: $showComposerEmoji) { emoji in
                    composerText += emoji
                }
                .frame(height: 300)
                .background(theme.background)
                .clipShape(RoundedRectangle(cornerRadius: theme.radiusLG))
                .shadow(radius: 8)
                .transition(.move(edge: .bottom))
            }
        }
        .overlay(alignment: .bottom) {
            if showResonateEmoji {
                CCEmojiPicker(isShowing: $showResonateEmoji) { emoji in
                    resonateMessage += emoji
                }
                .frame(height: 300)
                .background(theme.background)
                .clipShape(RoundedRectangle(cornerRadius: theme.radiusLG))
                .shadow(radius: 8)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showComposerEmoji)
        .animation(.easeInOut(duration: 0.25), value: showResonateEmoji)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 11))
                    .foregroundColor(theme.primaryMuted)
                Text("\(viewModel.onlineCount) 人此刻")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(theme.primaryMuted.opacity(0.2))
            .cornerRadius(theme.radiusSM)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { coordinator.navigate(to: .encourageChain) }) {
                HStack(spacing: 2) {
                    Text("🔥").font(.system(size: 13))
                    Text("鼓励链").font(.system(size: 13))
                }
                .foregroundColor(theme.warm)
            }
        }
    }

    // MARK: - List

    private var resonanceList: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacingMD) {
                ForEach(viewModel.resonanceItems) { item in
                    resonanceCard(item)
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
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                        .padding(.vertical, theme.spacingMD)
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Card

    private func resonanceCard(_ item: CCResonanceDisplayItem) -> some View {
        HStack(spacing: 0) {
            // Left emotion color strip (4px per spec)
            RoundedRectangle(cornerRadius: 2)
                .fill(item.emotionColorValue)
                .frame(width: 4)
                .padding(.vertical, theme.spacingMD)

            VStack(alignment: .leading, spacing: theme.spacingSM) {
                // Header: emotion label + time
                HStack(spacing: theme.spacingSM) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.emotionColorValue)
                            .frame(width: 8, height: 8)
                        Text(item.emotion)
                            .font(.system(size: 13))
                            .foregroundColor(item.emotionColorValue)
                    }
                    Spacer()
                    Text(item.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                }

                // Content (max 280 chars per spec, fold after 5 lines)
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(theme.textPrimary)
                    .lineSpacing(6)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Bottom: resonance count + actions
                HStack(spacing: theme.spacingLG) {
                    // Resonance count — tapping opens resonate sheet per spec
                    Button(action: {
                        CCHaptic.light()
                        resonateTarget = item
                        resonateMessage = ""
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.softPink)
                            Text("\(item.resonanceCount) 人共鸣")
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // "我也想说"
                    Button(action: { showComposer = true }) {
                        Label("我也想说", systemImage: "bubble.left")
                            .font(.system(size: 12))
                            .foregroundColor(theme.primaryLight)
                    }
                    .buttonStyle(.plain)

                    // "分享共鸣"
                    Button(action: {
                        CCHaptic.light()
                        shareItem = item
                    }) {
                        Label("分享共鸣", systemImage: "square.and.arrow.up")
                            .font(.system(size: 12))
                            .foregroundColor(theme.primaryLight)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, theme.spacingSM)
            .padding(.vertical, theme.spacingMD)
            .padding(.trailing, theme.spacingMD)
        }
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
    }

    // MARK: - Floating Compose Button

    private var composeFAB: some View {
        Button(action: { showComposer = true }) {
            HStack(spacing: 6) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 16))
                Text("写下心情")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(theme.primary)
            .cornerRadius(24)
            .shadow(color: theme.primary.opacity(0.3), radius: 6, y: 2)
        }
        .padding(.trailing, theme.spacingLG)
        .padding(.bottom, theme.spacingMD)
    }

    // MARK: - Compose Sheet

    private var composeSheet: some View {
        NavigationStack {
            VStack(spacing: theme.spacingMD) {
                HStack {
                    Spacer()

                    Button(action: { showComposerEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(theme.primary)
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
                                    ? theme.primary : theme.textMuted
                            )
                            .clipShape(Circle())
                    }
                    .disabled(composerText.trimmingCharacters(in: .whitespaces).count < 3)
                }

                TextField("分享你的心情，与千万人共鸣…", text: $composerText, axis: .vertical)
                    .focused($composerFocused)
                    .font(.system(size: 15))
                    .lineLimit(4...10)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                Spacer()
            }
            .padding(theme.spacingLG)
            .background(theme.background)
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
        VStack(alignment: .leading, spacing: theme.spacingLG) {
            // Quote the post
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                    Text(item.emotion)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(item.emotionColorValue)
                    Text("·").foregroundColor(theme.textMuted)
                    Text(item.timeAgo)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textMuted)
                }
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(theme.textPrimary)
                    .lineSpacing(5)
                    .lineLimit(3)
            }
            .padding(theme.spacingMD)
            .background(theme.surface)
            .cornerRadius(theme.radiusMD)

            Text("我也有过这种感觉")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.textPrimary)

            Text("你愿意附上一句鼓励吗？（选填）")
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)

            HStack(alignment: .bottom, spacing: 8) {
                TextField("一句温暖的话…", text: $resonateMessage, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(2...4)
                    .padding(theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                Button(action: { showResonateEmoji.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(theme.softGreen)
                .cornerRadius(theme.radiusMD)
            }

            Spacer()
        }
        .padding(theme.spacingLG)
        .background(theme.background)
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
