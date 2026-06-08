import SwiftUI

struct CCVoiceCheckinView: View {
    @Environment(\.ccAppTheme) private var theme
    @State private var isRecording = false
    @State private var recorded = false
    @State private var duration = 0
    @State private var bars: [CGFloat] = Array(repeating: 8, count: 30)
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: theme.spacingLG) {
            Spacer()

            if !recorded {
                Text("随便说什么都好，这里不评判…").font(.system(size: 18)).foregroundColor(theme.textSecondary)

                // Waveform animation
                HStack(spacing: 2) {
                    ForEach(0..<30, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isRecording ? Color(hex: "5A7A8A").opacity(0.6 + Double(bars[i]) / 100) : Color(hex: "B8D4E3"))
                            .frame(width: 3, height: max(4, bars[i]))
                    }
                }
                .frame(height: 80).padding(.vertical, 32)

                // Timer
                Text(String(format: "语音备忘 %02d:%02d", duration / 60, duration % 60))
                    .font(.system(size: 32, weight: .light)).foregroundColor(Color(hex: "5A7A8A"))
                if isRecording {
                    Circle().fill(Color(hex: "E57373")).frame(width: 8, height: 8).opacity(duration % 2 == 0 ? 1 : 0.3)
                }

                // Record button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "B8D4E3"), lineWidth: 3).frame(width: 100, height: 100)
                        Circle()
                            .fill(isRecording ? Color(hex: "E57373") : Color(hex: "5A7A8A"))
                            .frame(width: isRecording ? 70 : 80, height: isRecording ? 70 : 80)
                            .animation(.easeInOut(duration: 0.3), value: isRecording)
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isRecording = true }
                        .onEnded { _ in isRecording = false; recorded = true }
                )

                Text("按住说话…").font(.system(size: 14)).foregroundColor(theme.textMuted)
            } else {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 64)).foregroundColor(Color(hex: "66BB6A"))
                Text("录好了").font(.system(size: 22, weight: .bold))
                Text("语音备忘 \(String(format: "%02d:%02d", duration / 60, duration % 60))").font(.system(size: 16))
                    .foregroundColor(theme.textSecondary)

                HStack(spacing: 24) {
                    Button("重新录制") { recorded = false; duration = 0 }.foregroundColor(theme.textSecondary)
                    Button("保存") {}.fontWeight(.semibold).foregroundColor(.white)
                        .padding(.horizontal, 32).padding(.vertical, 12)
                        .background(Color(hex: "5A7A8A")).cornerRadius(theme.radiusMD)
                }
            }

            Spacer()
        }
        .padding()
        .background(theme.background)
        .navigationTitle("语音打卡")
        .onReceive(timer) { _ in
            if isRecording {
                duration += 1
                bars = bars.map { _ in CGFloat.random(in: 4...60) }
            }
        }
    }
}
