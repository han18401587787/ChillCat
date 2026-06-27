import SwiftUI
struct CCJournalDetailView: View {
    let entry: CCXuanAPI.JournalEntry

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.lg) {
                VStack(spacing: XuanSpacing.sm) {
                    Image(systemName: CCEmotion.allCases.first(where:{$0.rawValue==entry.emotion})?.iconName ?? "circle.fill")
                        .font(.system(size:64)).foregroundColor(emotionColor(entry.emotion))
                        .frame(width:100,height:100).background(emotionColor(entry.emotion).opacity(0.1)).cornerRadius(XuanRadius.xl)
                    Text(entry.emotion).font(.system(size:24,weight:.bold))
                    Text(entry.hasDoodle ? "含涂鸦" : "纯文字").font(.system(size:13)).foregroundColor(Color.xuanTextTertiary)
                }.padding(.top,XuanSpacing.xl)
                VStack(alignment:.leading,spacing:XuanSpacing.sm) {
                    Text(entry.note.isEmpty ? "（未记录文字）" : entry.note).font(.system(size:16)).lineSpacing(6).foregroundColor(entry.note.isEmpty ? Color.xuanTextTertiary : Color.xuanTextPrimary)
                }.padding().background(Color.xuanWhite).cornerRadius(XuanRadius.md)
                HStack {
                    Text("📅 \(entry.checkinDate)").font(.system(size:13)).foregroundColor(Color.xuanTextTertiary)
                    Spacer()
                    Text("🕐 \(entry.createdAt)").font(.system(size:13)).foregroundColor(Color.xuanTextTertiary)
                }
            }.padding()
        }.background(Color.xuanApricotBg).navigationTitle("日记详情")
    }
    private func emotionColor(_ name: String) -> Color {
        switch name {
        case "平静": return Color.xuanMint
        case "开心": return Color.xuanApricotDark
        case "疲惫": return Color.xuanInfo
        case "焦虑": return Color(hex: "A085C6")
        case "委屈": return Color.xuanPink
        case "烦躁": return Color.xuanDanger
        case "易怒": return Color.xuanApricotDark
        case "内耗": return Color.xuanTextTertiary
        case "孤独": return Color(hex: "A8C9D7")
        case "迷茫": return Color(hex: "D9C8E3")
        default: return Color.xuanInfo
        }
    }
}
