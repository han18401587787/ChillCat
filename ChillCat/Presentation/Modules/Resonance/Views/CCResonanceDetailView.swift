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
    @Environment(\.ccAppTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

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
            VStack(spacing: theme.spacingLG) {
                // 原始卡片（全内容展开）
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(item.emotionColorValue)
                            .frame(width: 4)
                            .padding(.vertical, theme.spacingMD)

                        VStack(alignment: .leading, spacing: theme.spacingSM) {
                            HStack(spacing: theme.spacingSM) {
                                HStack(spacing: 4) {
                                    Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                                    Text(item.emotion).font(.system(size: 13)).foregroundColor(item.emotionColorValue)
                                }
                                Spacer()
                                Text(item.timeAgo).font(.system(size: 12)).foregroundColor(theme.textMuted)
                            }

                            Text(item.content)
                                .font(.system(size: 15))
                                .foregroundColor(theme.textPrimary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: theme.spacingLG) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill").font(.system(size: 14)).foregroundColor(theme.softPink)
                                    Text("\(item.resonanceCount) 人共鸣").font(.system(size: 13)).foregroundColor(theme.textSecondary)
                                }
                                Spacer()
                            }
                        }
                        .padding(.leading, theme.spacingSM)
                        .padding(.vertical, theme.spacingMD)
                        .padding(.trailing, theme.spacingMD)
                    }
                }
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusLG)

                // 共鸣回应列表
                if !replies.isEmpty {
                    VStack(alignment: .leading, spacing: theme.spacingSM) {
                        Text("回应 (\(replies.count))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.textPrimary)

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
        .overlay(alignment: .bottom) {
            if showEmoji {
                CCEmojiPicker(isShowing: $showEmoji) { emoji in
                    newReply += emoji
                }
                .frame(height: 300)
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showEmoji)
    }

    private func replyRow(_ reply: CCResonanceReplyDisplay) -> some View {
        HStack(alignment: .top, spacing: theme.spacingSM) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(theme.primaryMuted)

            VStack(alignment: .leading, spacing: 4) {
                Text("匿名用户")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Text(reply.content)
                    .font(.system(size: 14))
                    .foregroundColor(theme.textPrimary)
                    .lineSpacing(4)
                Text(reply.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(theme.spacingSM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surface)
        .cornerRadius(theme.radiusSM)
    }

    private var replyInputSection: some View {
        VStack(spacing: theme.spacingSM) {
            Divider()
            HStack(spacing: theme.spacingSM) {
                TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                    .focused($isFocused)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                    .lineLimit(1...3)

                Button(action: { showEmoji.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }

                Button(action: { sendReply() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(newReply.trimmingCharacters(in: .whitespaces).isEmpty ? theme.textMuted : theme.primary)
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
