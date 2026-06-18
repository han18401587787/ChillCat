//
//  CCResonanceView.swift
//  绪安 - 共鸣墙
//

import SwiftUI

struct CCResonanceView: View {
    @State private var viewModel = CCResonanceViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

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
        // Emoji overlays (V3)
        .cc_emojiPickerV3Overlay(isShowing: $showComposerEmoji) { emoji in
            composerText += emoji.displayName
        }
        .cc_emojiPickerV3Overlay(isShowing: $showResonateEmoji) { emoji in
            resonateMessage += emoji.displayName
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
                    .foregroundColor(AppTheme.primaryMuted)
                Text("\(viewModel.onlineCount) 人此刻")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppTheme.primaryMuted.opacity(0.2))
            .cornerRadius(AppRadius.sm)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { coordinator.navigate(to: .encourageChain) }) {
                HStack(spacing: 2) {
                    Text("🔥").font(.system(size: 13))
                    Text("鼓励链").font(.system(size: 13))
                }
                .foregroundColor(AppTheme.warm)
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
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.vertical, AppSpacing.md)
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
                .padding(.vertical, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Header: emotion label + time
                HStack(spacing: AppSpacing.sm) {
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
                        .foregroundColor(AppTheme.textMuted)
                }

                // Content (max 280 chars per spec, fold after 5 lines)
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Bottom: resonance count + actions
                HStack(spacing: AppSpacing.lg) {
                    // Resonance count — tapping opens resonate sheet per spec
                    Button(action: {
                        CCHaptic.light()
                        resonateTarget = item
                        resonateMessage = ""
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.softPink)
                            Text("\(item.resonanceCount) 人共鸣")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // "我也想说"
                    Button(action: { showComposer = true }) {
                        Label("我也想说", systemImage: "bubble.left")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primaryLight)
                    }
                    .buttonStyle(.plain)

                    // "分享共鸣"
                    Button(action: {
                        CCHaptic.light()
                        shareItem = item
                    }) {
                        Label("分享共鸣", systemImage: "square.and.arrow.up")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primaryLight)
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
            .background(AppTheme.primary)
            .cornerRadius(24)
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 6, y: 2)
        }
        .padding(.trailing, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
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
                    .font(.system(size: 15))
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
            // Quote the post
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                    Text(item.emotion)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(item.emotionColorValue)
                    Text("·").foregroundColor(AppTheme.textMuted)
                    Text(item.timeAgo)
                        .font(.system(size: 13))
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
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text("你愿意附上一句鼓励吗？（选填）")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            HStack(alignment: .bottom, spacing: 8) {
                TextField("一句温暖的话…", text: $resonateMessage, axis: .vertical)
                    .font(.system(size: 15))
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(AppTheme.softGreen)
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
