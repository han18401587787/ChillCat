import SwiftUI

struct CCTreeHolePostDetailView: View {
    let post: CCResonancePost
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
            VStack(alignment: .leading, spacing: XuanSpacing.lg) {
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
                        .foregroundColor(Color.xuanTextTertiary)
                }

                // Post content
                Text(post.content)
                    .font(.system(size: 17))
                    .lineSpacing(6)
                    .foregroundColor(Color.xuanTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .padding(.vertical, XuanSpacing.sm)

                // Resonance section
                VStack(spacing: XuanSpacing.sm) {
                    HStack {
                        Text("\(post.formattedResonance) 人共鸣")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.xuanTextPrimary)
                        Spacer()
                    }

                    // Resonate button
                    Button(action: { showReplySheet = true }) {
                        HStack(spacing: 6) {
                            CCIconMapper.image(for: didResonate ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                            Text(didResonate ? "已共鸣" : "我也有过这种感觉")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(didResonate ? Color.xuanDanger : Color.xuanApricot)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(didResonate ? Color.xuanPink.opacity(0.15) : Color.xuanApricot.opacity(0.08))
                        .cornerRadius(XuanRadius.md)
                    }
                    .accessibilityIdentifier("treehole_detail_resonate")

                    // Resonance replies
                    if isLoadingReplies {
                        HStack { Spacer(); ProgressView(); Spacer() }.padding()
                    } else if replies.isEmpty {
                        Text("成为第一个表达共鸣的人")
                            .font(.system(size: 14))
                            .foregroundColor(Color.xuanTextTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, XuanSpacing.lg)
                    } else {
                        VStack(spacing: XuanSpacing.sm) {
                            ForEach(replies) { reply in
                                HStack(alignment: .top, spacing: 10) {
                                    Image("resonance_like")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.xuanPink)
                                        .padding(.top, 2)
                                    Text(reply.content ?? "")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.xuanTextSecondary)
                                        .lineSpacing(4)
                                    Spacer()
                                    Text(timeAgo(from: reply.createdAt ?? ""))
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.xuanTextTertiary)
                                }
                                .padding()
                                .background(Color.xuanSurface)
                                .cornerRadius(XuanRadius.sm)
                            }
                        }
                    }
                }

                Text("共鸣墙没有评判，只有温柔理解。")
                    .font(.system(size: 13))
                    .foregroundColor(Color.xuanTextTertiary)
                    .padding(.top, XuanSpacing.sm)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color.xuanApricotBg)
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
                .foregroundColor(Color.xuanTextPrimary)

            TextField("说一句鼓励的话吧", text: $replyMessage, axis: .vertical)
                .font(.system(size: 15))
                .padding()
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.md)
                .lineLimit(2...4)
                .accessibilityIdentifier("treehole_detail_reply_input")

            HStack(spacing: 12) {
                Button("取消") { showReplySheet = false }
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)

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
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("treehole_detail_send_reply")
            }
        }
        .padding()
        .background(Color.xuanApricotBg)
    }

    // MARK: - Helpers

    private func loadReplies() async {
        isLoadingReplies = true
        do {
            let _ = try await CCXuanAPI.getResonanceDetail(id: Int64(post.id) ?? 0)
            // getResonanceDetail 返回 ResonanceItem（扁平结构），replies 暂为空
            replies = []
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
        case "softGreen": return Color.xuanSuccess
        case "warmLight": return Color.xuanApricotLight
        case "primaryMuted": return Color.xuanApricot.opacity(0.6)
        case "softPurple": return Color(hex: "A085C6").opacity(0.5)
        case "softPink": return Color.xuanPink
        case "primaryLight": return Color.xuanApricotLight
        case "error": return Color.xuanDanger
        case "softPurpleLight": return Color(hex: "A085C6").opacity(0.25)
        case "warm": return Color.xuanApricotDark
        default: return Color.xuanApricot.opacity(0.6)
        }
    }
}
