import SwiftUI

/// 绪安自建 Douyin 风格表情包
struct CCEmoji: Identifiable, Hashable {
    let id: String; let text: String; let category: String
    static let all: [CCEmoji] = [
        // 基础情绪
        CCEmoji(id:"e1",text:"😊",category:"基础"),CCEmoji(id:"e2",text:"😢",category:"基础"),
        CCEmoji(id:"e3",text:"😡",category:"基础"),CCEmoji(id:"e4",text:"😰",category:"基础"),
        CCEmoji(id:"e5",text:"😴",category:"基础"),CCEmoji(id:"e6",text:"🥰",category:"基础"),
        CCEmoji(id:"e7",text:"😤",category:"基础"),CCEmoji(id:"e8",text:"🤗",category:"基础"),
        // 治愈系
        CCEmoji(id:"h1",text:"🌸",category:"治愈"),CCEmoji(id:"h2",text:"🌿",category:"治愈"),
        CCEmoji(id:"h3",text:"☀️",category:"治愈"),CCEmoji(id:"h4",text:"🌙",category:"治愈"),
        CCEmoji(id:"h5",text:"💚",category:"治愈"),CCEmoji(id:"h6",text:"🕊️",category:"治愈"),
        CCEmoji(id:"h7",text:"🍃",category:"治愈"),CCEmoji(id:"h8",text:"💫",category:"治愈"),
        // 鼓励系
        CCEmoji(id:"c1",text:"💪",category:"鼓励"),CCEmoji(id:"c2",text:"🔥",category:"鼓励"),
        CCEmoji(id:"c3",text:"✨",category:"鼓励"),CCEmoji(id:"c4",text:"🌟",category:"鼓励"),
        CCEmoji(id:"c5",text:"🎯",category:"鼓励"),CCEmoji(id:"c6",text:"🏆",category:"鼓励"),
        CCEmoji(id:"c7",text:"👏",category:"鼓励"),CCEmoji(id:"c8",text:"💖",category:"鼓励"),
    ]
    static var categories: [String] { ["基础","治愈","鼓励"] }
    static func byCategory(_ cat: String) -> [CCEmoji] { all.filter { $0.category == cat } }
}

struct CCEmojiPicker: View {
    @Binding var isShowing: Bool
    var onSelect: (String) -> Void
    @State private var selectedCat = "基础"

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedCat) {
                ForEach(CCEmoji.categories, id: \.self) { Text($0).tag($0) }
            }.pickerStyle(.segmented).padding()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 12) {
                    ForEach(CCEmoji.byCategory(selectedCat)) { emoji in
                        Button(action: { onSelect(emoji.text); isShowing = false }) {
                            Text(emoji.text).font(.system(size: 32))
                        }
                    }
                }.padding()
            }
        }
        .background(Color(hex:"F9F6F2"))
    }
}
