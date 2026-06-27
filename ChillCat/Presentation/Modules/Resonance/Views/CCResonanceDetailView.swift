//
//  CCResonanceDetailView.swift
//  绪安 - 共鸣详情 (Ardot v3)
//
//  对照设计图像素级还原
//  包含：帖子详情（全内容展开）、回应列表、回复输入框

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
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    originalPostCard
                    if !replies.isEmpty { repliesSection }
                    Spacer().frame(height: 80) // 底部操作栏空间
                }
                .padding(AppSpacing.lg)
            }

            // 底部固定操作栏
            bottomActionBar
        }
        .background(AppTheme.background)
        .cc_emojiPickerOverlay(isShowing: $showEmoji) { emoji in
            newReply += emoji.displayName
        }
        .animation(.easeInOut, value: showEmoji)
    }

    // MARK: - 底部固定操作栏
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().foregroundColor(AppTheme.border)

            HStack(spacing: AppSpacing.md) {
                // 共鸣按钮
                Button(action: { /* 共鸣 */ }) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.warmPink)
                        Text("共鸣")
                            .font(AppFont.bodyBold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(item.resonanceCount)")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppTheme.warmPink.opacity(0.08))
                    .cornerRadius(AppRadius.full)
                }

                // 鼓励按钮
                Button(action: {
                    isFocused = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.warmGold)
                        Text("鼓励")
                            .font(AppFont.bodyBold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(replies.count)")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppTheme.warmGold.opacity(0.08))
                    .cornerRadius(AppRadius.full)
                }

                Spacer()

                // 回复输入框
                HStack(spacing: AppSpacing.sm) {
                    TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                        .focused($isFocused)
                        .font(AppFont.footnote)
                        .lineLimit(1)

                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Button(action: { sendReply() }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                newReply.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? AppTheme.textMuted
                                    : AppTheme.primary
                            )
                            .clipShape(Circle())
                    }
                    .disabled(newReply.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.full)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(.regularMaterial)
        }
    }

    // MARK: - 原始帖子卡片
    private var originalPostCard: some View {
        HStack(spacing: 0) {
            // 情绪色条
            RoundedRectangle(cornerRadius: 2)
                .fill(item.emotionColorValue)
                .frame(width: 4)
                .padding(.vertical, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // 头：情绪标签 + 时间
                HStack(spacing: AppSpacing.sm) {
                    HStack(spacing: 4) {
                        Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                        Text(item.emotion)
                            .font(AppFont.footnote)
                            .foregroundColor(item.emotionColorValue)
                    }
                    Spacer()
                    Text(item.timeAgo)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }

                // 内容（全展开）
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                // 共鸣数
                HStack(spacing: AppSpacing.lg) {
                    Button(action: { /* 共鸣互动 */ }) {
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
                }
            }
            .padding(.leading, AppSpacing.sm)
            .padding(.vertical, AppSpacing.md)
            .padding(.trailing, AppSpacing.md)
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 回应区
    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("回应 (\(replies.count))")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, AppSpacing.sm)

            ForEach(replies) { reply in
                replyRow(reply)
            }
        }
    }

    private func replyRow(_ reply: CCResonanceReplyDisplay) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // 匿名头像
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.primaryMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("匿名用户")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text(reply.timeAgo)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }
                Text(reply.content)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - 回复输入区
    private var replyInputSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Divider()
                .foregroundColor(AppTheme.border)

            HStack(spacing: AppSpacing.sm) {
                TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                    .focused($isFocused)
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.lg)
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
                        .padding(12)
                        .background(
                            newReply.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppTheme.textMuted
                                : AppTheme.primary
                        )
                        .clipShape(Circle())
                }
                .disabled(newReply.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - 数据加载
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
                await loadDetail()
            } catch {
                newReply = replyText
            }
        }
    }
}
