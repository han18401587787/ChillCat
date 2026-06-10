import SwiftUI

struct CCTreeHolePostDetailView: View {
    let post: CCResonancePost
    @Environment(\.ccAppTheme) private var theme
    @State private var resonanceCount: Int
    @State private var didResonate = false
    @State private var showReplySheet = false
    @State private var replyMessage = ""
    @State private var replies: [CCXuanAPI.ResonanceReply] = []
    @State private var isLoadingReplies = false

    init(post: CCResonancePost) {
        self.post = post
        _resonanceCount = State(initialValue: post.resonanceCount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacingLG) {
                // Post header
                HStack {
                    Circle()
                        .fill(emotionColorFor(post.emotionColor))
                        .frame(width: 10, height: 10)
                    Text(post.emotion)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(emotionColorFor(post.emotionColor))
                    Spacer()
                    Text(post.timeAgo)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textMuted)
                }

                // Post content
                Text(post.content)
                    .font(.system(size: 17))
                    .lineSpacing(6)
                    .foregroundColor(theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .padding(.vertical, theme.spacingSM)

                // Resonance section
                VStack(spacing: theme.spacingSM) {
                    HStack {
                        Text("\(post.formattedResonance) 人共鸣")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.textPrimary)
                        Spacer()
                    }

                    // Resonate button
                    Button(action: { showReplySheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: didResonate ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                            Text(didResonate ? "已共鸣" : "我也有过这种感觉")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(didResonate ? theme.error : theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(didResonate ? theme.softPink.opacity(0.15) : theme.primary.opacity(0.08))
                        .cornerRadius(theme.radiusMD)
                    }

                    // Resonance replies
                    if isLoadingReplies {
                        HStack { Spacer(); ProgressView(); Spacer() }.padding()
                    } else if replies.isEmpty {
                        Text("成为第一个表达共鸣的人")
                            .font(.system(size: 14))
                            .foregroundColor(theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacingLG)
                    } else {
                        VStack(spacing: theme.spacingSM) {
                            ForEach(replies) { reply in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(theme.softPink)
                                        .padding(.top, 2)
                                    Text(reply.content)
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.textSecondary)
                                        .lineSpacing(4)
                                    Spacer()
                                    Text(timeAgo(from: reply.createdAt))
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.textMuted)
                                }
                                .padding()
                                .background(theme.surface)
                                .cornerRadius(theme.radiusSM)
                            }
                        }
                    }
                }

                Text("共鸣墙没有评判，只有温柔理解。")
                    .font(.system(size: 13))
                    .foregroundColor(theme.textMuted)
                    .padding(.top, theme.spacingSM)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(theme.background)
        .navigationTitle("共鸣详情")
        .sheet(isPresented: $showReplySheet) {
            replySheetView
                .presentationDetents([.height(260)])
        }
        .task { await loadReplies() }
    }

    // MARK: - Reply Sheet

    private var replySheetView: some View {
        VStack(spacing: 16) {
            Text("我也有过这种感觉")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.textPrimary)

            TextField("说一句鼓励的话吧", text: $replyMessage, axis: .vertical)
                .font(.system(size: 15))
                .padding()
                .background(theme.surface)
                .cornerRadius(theme.radiusMD)
                .lineLimit(2...4)

            HStack(spacing: 12) {
                Button("取消") { showReplySheet = false }
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)

                Button(action: {
                    CCHaptic.success()
                    let msg = replyMessage
                    if !msg.isEmpty {
                        let newReply = CCXuanAPI.ResonanceReply(
                            id: Int64(Date().timeIntervalSince1970),
                            content: msg,
                            createdAt: ISO8601DateFormatter().string(from: Date())
                        )
                        replies.insert(newReply, at: 0)
                    }
                    Task {
                        guard let id = Int64(post.id) else { return }
                        do {
                            try await CCXuanAPI.hugResonance(id: id, message: msg.isEmpty ? nil : msg)
                            resonanceCount += 1
                            didResonate = true
                            NotificationCenter.default.post(name: .treeHoleDidUpdate, object: nil)
                        } catch {}
                    }
                    replyMessage = ""
                    showReplySheet = false
                }) {
                    Text("发送鼓励")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.primary)
                        .cornerRadius(theme.radiusMD)
                }
            }
        }
        .padding()
        .background(theme.background)
    }

    // MARK: - Helpers

    private func loadReplies() async {
        isLoadingReplies = true
        do {
            let detail = try await CCXuanAPI.getResonanceDetail(id: Int64(post.id) ?? 0)
            replies = detail.replies
        } catch { /* keep empty */ }
        isLoadingReplies = false
    }

    private func timeAgo(from iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let d = Date().timeIntervalSince(date)
        if d < 60 { return "刚刚" }; if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }; return "\(Int(d/86400))天前"
    }

    private func emotionColorFor(_ colorName: String) -> Color {
        switch colorName {
        case "softGreen": return theme.softGreen
        case "warmLight": return theme.warmLight
        case "primaryMuted": return theme.primaryMuted
        case "softPurple": return theme.softPurple
        case "softPink": return theme.softPink
        case "primaryLight": return theme.primaryLight
        case "error": return theme.error
        case "softPurpleLight": return theme.softPurpleLight
        case "warm": return theme.warm
        default: return theme.primaryMuted
        }
    }
}
