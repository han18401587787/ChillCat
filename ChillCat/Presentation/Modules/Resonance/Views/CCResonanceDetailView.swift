//
//  CCResonanceDetailView.swift
//  绪安 - 共鸣详情
//

import SwiftUI

struct CCResonanceDetailView: View {
    let item: CCResonanceDisplayItem
    @State private var replies: [CCResonanceReplyDisplay] = []
    @State private var newReply: String = ""
    @State private var showEmoji = false
    @State private var isLoading = true
    @State private var error: Error?
    @Environment(CCAppCoordinator.self) private var coordinator
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let error, replies.isEmpty && !isLoading {
                CCErrorView(error: error) { await loadDetail() }
            } else if isLoading && replies.isEmpty {
                CCLoadingView(message: "加载中...")
            } else {
                detailContent
            }
        }
        .navigationTitle("共鸣详情")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
    }

    private var detailContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 原始卡片（全内容展开）
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(item.emotionColorValue)
                            .frame(width: 4)
                            .padding(.vertical, AppSpacing.md)

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            HStack(spacing: AppSpacing.sm) {
                                HStack(spacing: 4) {
                                    Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                                    Text(item.emotion).font(.system(size: 13)).foregroundColor(item.emotionColorValue)
                                }
                                Spacer()
                                Text(item.timeAgo).font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                            }

                            Text(item.content)
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: AppSpacing.lg) {
                                Button(action: { /* 共鸣互动 */ }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill").font(.system(size: 14)).foregroundColor(AppTheme.softPink)
                                        Text("\(item.resonanceCount) 人共鸣").font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                        .padding(.leading, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.md)
                        .padding(.trailing, AppSpacing.md)
                    }
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.lg)

                // 共鸣回应列表
                if !replies.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("回应 (\(replies.count))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        ForEach(replies) { reply in
                            replyRow(reply)
                        }
                    }
                }

                // 输入区域
                replyInputSection
            }
            .padding()
        }
        .cc_emojiPickerOverlay(isShowing: $showEmoji) { emoji in
            newReply += emoji.displayName
        }
        .animation(.easeInOut, value: showEmoji)
    }

    private func replyRow(_ reply: CCResonanceReplyDisplay) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primaryMuted)

            VStack(alignment: .leading, spacing: 4) {
                Text("匿名用户")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text(reply.content)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
                Text(reply.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(AppRadius.sm)
    }

    private var replyInputSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Divider()
            HStack(spacing: AppSpacing.sm) {
                TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                    .focused($isFocused)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                    .lineLimit(1...3)

                Button(action: { showEmoji.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primary)
                }

                Button(action: { sendReply() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(newReply.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.textMuted : AppTheme.primary)
                        .clipShape(Circle())
                }
                .disabled(newReply.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func loadDetail() async {
        isLoading = true
        guard let id = Int64(item.id) else { isLoading = false; return }
        do {
            let resp = try await CCXuanAPI.getResonanceDetail(id: id)
            replies = resp.replies.map { r in
                CCResonanceReplyDisplay(
                    id: String(r.id),
                    content: r.content,
                    createdAt: ISO8601DateFormatter().date(from: r.createdAt) ?? Date()
                )
            }
        } catch { self.error = error }
        isLoading = false
    }

    private func sendReply() {
        let text = newReply.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        guard let id = Int64(item.id) else { return }
        let replyText = text
        newReply = ""
        isFocused = false
        CCHaptic.medium()
        Task {
            do {
                try await CCXuanAPI.hugResonance(id: id, message: replyText)
                // Reload replies to show the new one
                await loadDetail()
            } catch {
                // Silently revert — the reply can be retried
                newReply = replyText
            }
        }
    }
}
