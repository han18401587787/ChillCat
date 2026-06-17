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
        let m:[String:String]=["平静":"66BB6A","开心":"C9A063","疲惫":"7A9AAA","焦虑":"D4C8E8","委屈":"E8B8C8","孤独":"A8C9D7","烦躁":"E57373","迷茫":"D9C8E3","易怒":"8B6F47","内耗":"AAAAAA"]
        return Color(hex:m[name] ?? "B8D4E3")
    }
}
