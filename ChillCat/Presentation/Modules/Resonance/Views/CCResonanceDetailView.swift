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
            Color.xuanApricotBg.ignoresSafeArea()

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
                VStack(spacing: XuanSpacing.lg) {
                    originalPostCard
                    if !replies.isEmpty { repliesSection }
                    Spacer().frame(height: 80) // 底部操作栏空间
                }
                .padding(XuanSpacing.lg)
            }

            // 底部固定操作栏
            bottomActionBar
        }
        .background(Color.xuanApricotBg)
        .cc_emojiPickerOverlay(isShowing: $showEmoji) { emoji in
            newReply += emoji.displayName
        }
        .animation(.easeInOut, value: showEmoji)
    }

    // MARK: - 底部固定操作栏
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().foregroundColor(Color.xuanBorder)

            HStack(spacing: XuanSpacing.md) {
                // 共鸣按钮
                Button(action: { /* 共鸣 */ }) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.xuanPink)
                        Text("共鸣")
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("\(item.resonanceCount)")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.xuanPink.opacity(0.08))
                    .cornerRadius(XuanRadius.full)
                }

                // 鼓励按钮
                Button(action: {
                    isFocused = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.xuanApricotDark)
                        Text("鼓励")
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("\(replies.count)")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                    .padding(.horizontal, XuanSpacing.lg)
                    .padding(.vertical, XuanSpacing.sm)
                    .background(Color.xuanApricotDark.opacity(0.08))
                    .cornerRadius(XuanRadius.full)
                }

                Spacer()

                // 回复输入框
                HStack(spacing: XuanSpacing.sm) {
                    TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                        .focused($isFocused)
                        .font(XuanFont.bodyS)
                        .lineLimit(1)

                    Button(action: { showEmoji.toggle() }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(Color.xuanTextSecondary)
                    }

                    Button(action: { sendReply() }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                newReply.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.xuanTextTertiary
                                    : Color.xuanApricot
                            )
                            .clipShape(Circle())
                    }
                    .disabled(newReply.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, XuanSpacing.xs)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.full)
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.vertical, XuanSpacing.sm)
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
                .padding(.vertical, XuanSpacing.md)

            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                // 头：情绪标签 + 时间
                HStack(spacing: XuanSpacing.sm) {
                    HStack(spacing: 4) {
                        Circle().fill(item.emotionColorValue).frame(width: 8, height: 8)
                        Text(item.emotion)
                            .font(XuanFont.bodyS)
                            .foregroundColor(item.emotionColorValue)
                    }
                    Spacer()
                    Text(item.timeAgo)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }

                // 内容（全展开）
                Text(item.content)
                    .font(.system(size: 15))
                    .foregroundColor(Color.xuanTextPrimary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                // 共鸣数
                HStack(spacing: XuanSpacing.lg) {
                    Button(action: { /* 共鸣互动 */ }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color.xuanPink)
                            Text("\(item.resonanceCount) 人共鸣")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .padding(.leading, XuanSpacing.sm)
            .padding(.vertical, XuanSpacing.md)
            .padding(.trailing, XuanSpacing.md)
        }
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
        .xuanCardShadow()
    }

    // MARK: - 回应区
    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("温暖的回应 (\(replies.count))")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
                .padding(.top, XuanSpacing.sm)

            ForEach(replies) { reply in
                replyRow(reply)
            }
        }
    }

    private func replyRow(_ reply: CCResonanceReplyDisplay) -> some View {
        HStack(alignment: .top, spacing: XuanSpacing.md) {
            // 匿名头像
            ZStack {
                Circle()
                    .fill(Color.xuanApricot.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.xuanApricot.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("匿名用户")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text(reply.timeAgo)
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }
                Text(reply.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color.xuanTextPrimary)
                    .lineSpacing(4)
            }
        }
        .padding(XuanSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - 回复输入区
    private var replyInputSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            Divider()
                .foregroundColor(Color.xuanBorder)

            HStack(spacing: XuanSpacing.sm) {
                TextField("附上一句鼓励...", text: $newReply, axis: .vertical)
                    .focused($isFocused)
                    .font(XuanFont.bodyL)
                    .padding(XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.lg)
                    .lineLimit(1...3)

                Button(action: { showEmoji.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(Color.xuanApricot)
                }

                Button(action: { sendReply() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            newReply.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.xuanTextTertiary
                                : Color.xuanApricot
                        )
                        .clipShape(Circle())
                }
                .disabled(newReply.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.top, XuanSpacing.sm)
    }

    // MARK: - 数据加载
    private func loadDetail() async {
        isLoading = true
        guard let id = Int64(item.id) else { isLoading = false; return }
        do {
            let resp = try await CCXuanAPI.getResonanceDetail(id: id)
            replies = resp.resolvedReplies.map { r in
                CCResonanceReplyDisplay(
                    id: String(r.id),
                    content: r.content ?? "",
                    createdAt: ISO8601DateFormatter().date(from: r.createdAt ?? "") ?? Date()
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
