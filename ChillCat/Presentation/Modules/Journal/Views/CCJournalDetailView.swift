import SwiftUI
struct CCJournalDetailView: View {
    let entry: CCXuanAPI.JournalEntry

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: CCEmotion.allCases.first(where:{$0.rawValue==entry.emotion})?.iconName ?? "circle.fill")
                        .font(.system(size:64)).foregroundColor(emotionColor(entry.emotion))
                        .frame(width:100,height:100).background(emotionColor(entry.emotion).opacity(0.1)).cornerRadius(AppRadius.xl)
                    Text(entry.emotion).font(.system(size:24,weight:.bold))
                    Text(entry.hasDoodle ? "含涂鸦" : "纯文字").font(.system(size:13)).foregroundColor(AppTheme.textMuted)
                }.padding(.top,AppSpacing.xl)
                VStack(alignment:.leading,spacing:AppSpacing.sm) {
                    Text(entry.note.isEmpty ? "（未记录文字）" : entry.note).font(.system(size:16)).lineSpacing(6).foregroundColor(entry.note.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
                }.padding().background(AppTheme.cardBackground).cornerRadius(AppRadius.md)
                HStack {
                    Text("📅 \(entry.checkinDate)").font(.system(size:13)).foregroundColor(AppTheme.textMuted)
                    Spacer()
                    Text("🕐 \(entry.createdAt)").font(.system(size:13)).foregroundColor(AppTheme.textMuted)
                }
            }.padding()
        }.background(AppTheme.background).navigationTitle("日记详情")
    }
    private func emotionColor(_ name: String) -> Color {
        switch name {
        case "平静": return AppTheme.accentMint
        case "开心": return AppTheme.warmGold
        case "疲惫": return AppTheme.info
        case "焦虑": return AppTheme.warmPurple
        case "委屈": return AppTheme.warmPink
        case "烦躁": return AppTheme.crisisRed
        case "易怒": return AppTheme.warmGold
        case "内耗": return AppTheme.textMuted
        case "孤独": return Color(hex: "A8C9D7")
        case "迷茫": return Color(hex: "D9C8E3")
        default: return AppTheme.info
        }
    }
}
