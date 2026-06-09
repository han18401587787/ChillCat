import SwiftUI
import Combine

struct CCMeditationView: View {
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var breathing = false
    @State private var breathPhase = "吸气"
    @State private var timerRunning = false
    @State private var secondsElapsed = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {
                VStack(spacing: theme.spacingMD) {
                    Text("呼吸训练").font(.system(size: 22, weight: .bold))
                    Text("4-7-8 呼吸法").font(.system(size: 16)).foregroundColor(theme.textSecondary)

                    ZStack {
                        Circle().stroke(Color(hex: "B8D4E3").opacity(0.3), lineWidth: 2).frame(width: 200, height: 200)
                        Circle().trim(from: 0, to: breathing ? 1 : 0.4)
                            .stroke(Color(hex: "5A7A8A"), lineWidth: 3).frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(breathing ? .easeInOut(duration: 4).repeatForever() : .default, value: breathing)
                        VStack(spacing: 8) {
                            Text(breathPhase).font(.system(size: 28, weight: .light)).foregroundColor(Color(hex: "5A7A8A"))
                            if timerRunning {
                                Text("\(secondsElapsed / 60):\(String(format: "%02d", secondsElapsed % 60))").font(.system(size: 16)).foregroundColor(theme.textSecondary)
                            }
                        }
                    }

                    Button(action: { breathing.toggle(); timerRunning.toggle(); if !breathing { secondsElapsed = 0 } }) {
                        Text(breathing ? "结束" : "开始练习").fontWeight(.medium).foregroundColor(.white)
                            .frame(width: 160).padding(.vertical, 14)
                            .background(Color(hex: "5A7A8A")).cornerRadius(theme.radiusMD)
                    }
                }
                .padding(theme.spacingLG).background(theme.cardBackground).cornerRadius(theme.radiusLG)

                Text("练习计划").font(.system(size: 20, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)

                medCard(session: CCMeditationSession.presets[0])
                medCard(session: CCMeditationSession.presets[1])
                medCard(session: CCMeditationSession.presets[2])
            }.padding()
        }.background(theme.background).navigationTitle("冥想放松")
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            secondsElapsed += 1
            let cycle = secondsElapsed % 19
            if cycle < 4 { breathPhase = "吸气" }
            else if cycle < 11 { breathPhase = "屏息" }
            else { breathPhase = "呼气" }
        }
    }

    func medCard(session: CCMeditationSession) -> some View {
        Button {
            coordinator.navigate(to: .meditationPlayer(session: session))
        } label: {
            HStack(spacing: 16) {
                Image(systemName: session.category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: session.category.themeColor))
                    .frame(width: 56, height: 56)
                    .background(Color(hex: session.category.themeColor).opacity(0.15))
                    .cornerRadius(theme.radiusMD)
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title).font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.textPrimary)
                    Text(session.category.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondary)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "5A7A8A"))
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)
        }
    }
}
