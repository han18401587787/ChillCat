import SwiftUI
import Combine

// MARK: - 治愈空间 v3.0 (Ardot Design)
/// 对照截图 03_healing_space.png 像素级还原
/// 包含：冥想练习卡片、治愈音频（白噪音/森林/钢琴）、呼吸训练入口

struct CCMeditationView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var breathing = false
    @State private var breathPhase = "吸气"
    @State private var timerRunning = false
    @State private var secondsElapsed = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // 当前选中的音频类型
    @State private var selectedAudio: HealingAudioType = .rain

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                // 1. 冥想练习卡片列表
                meditationSection

                // 2. 治愈音频区
                healingAudioSection

                // 3. 呼吸训练入口
                breathingSection
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("治愈空间")
        .navigationBarTitleDisplayMode(.large)
        .onDisappear { timerRunning = false; breathing = false }
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            secondsElapsed += 1
            let cycle = secondsElapsed % 19
            if cycle < 4 { breathPhase = "吸气" }
            else if cycle < 11 { breathPhase = "屏息" }
            else { breathPhase = "呼气" }
        }
    }

    // MARK: - 冥想练习区
    private var meditationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("冥想练习")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                ForEach(CCMeditationSession.presets) { session in
                    meditationCard(session: session)
                }
            }
        }
    }

    private func meditationCard(session: CCMeditationSession) -> some View {
        NavigationLink(value: CCAppRoute.meditationPlayer(session: session)) {
            HStack(spacing: AppSpacing.lg) {
                // 左侧图标
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color(hex: session.category.themeColor).opacity(0.12))
                        .frame(width: 56, height: 56)

                    Image(systemName: session.category.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: session.category.themeColor))
                }

                // 中间文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(session.category.subtitle)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                // 播放按钮
                ZStack {
                    Circle()
                        .fill(Color(hex: session.category.themeColor).opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: session.category.themeColor))
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .xuanCardShadow()
        }
    }

    // MARK: - 治愈音频区
    private var healingAudioSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("治愈音频")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                audioCard(
                    type: .rain,
                    title: "白噪音·雨声",
                    subtitle: "模拟淅沥雨声，帮助平静思绪",
                    icon: "cloud.rain.fill",
                    color: Color(hex: "63B5F5")
                )
                audioCard(
                    type: .forest,
                    title: "森林声音",
                    subtitle: "鸟鸣与风吹树叶的自然之声",
                    icon: "leaf.fill",
                    color: Color(hex: "82C785")
                )
                audioCard(
                    type: .piano,
                    title: "钢琴曲",
                    subtitle: "舒缓的古典钢琴，放松身心",
                    icon: "music.quarternote.3",
                    color: Color(hex: "A085C6")
                )
            }
        }
    }

    private func audioCard(type: HealingAudioType, title: String, subtitle: String, icon: String, color: Color) -> some View {
        Button(action: {
            selectedAudio = type
            // TODO: 播放对应音频
        }) {
            HStack(spacing: AppSpacing.lg) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                // 播放/选中状态
                ZStack {
                    Circle()
                        .fill(selectedAudio == type ? color : color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: selectedAudio == type ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(selectedAudio == type ? .white : color)
                }
                .animation(.easeInOut(duration: 0.2), value: selectedAudio)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .xuanCardShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - 呼吸训练区
    private var breathingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("呼吸训练")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppSpacing.lg) {
                // 标题行
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("4-7-8 呼吸法")
                            .font(AppFont.h3)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("经典放松呼吸法，缓解焦虑")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }

                // 呼吸动画圆
                ZStack {
                    // 外圈
                    Circle()
                        .stroke(AppTheme.accentMint.opacity(0.2), lineWidth: 3)
                        .frame(width: 200, height: 200)

                    // 进度圈
                    Circle()
                        .trim(from: 0, to: breathing ? 1 : 0.4)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.accentMint, AppTheme.accentMintDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(breathing ? .easeInOut(duration: 4).repeatForever() : .default, value: breathing)

                    // 中心文字
                    VStack(spacing: AppSpacing.sm) {
                        Text(breathPhase)
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(AppTheme.accentMintDark)

                        if timerRunning {
                            Text("\(secondsElapsed / 60):\(String(format: "%02d", secondsElapsed % 60))")
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }

                // 操作按钮
                Button(action: {
                    breathing.toggle()
                    timerRunning.toggle()
                    if !breathing { secondsElapsed = 0 }
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: breathing ? "stop.fill" : "play.fill")
                            .font(.system(size: 16))
                        Text(breathing ? "结束练习" : "开始练习")
                            .font(AppFont.buttonLabel)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.accentMint, AppTheme.accentMintDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppRadius.lg)
                }
            }
            .padding(AppSpacing.xl)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .xuanCardShadow()
        }
    }
}

// MARK: - 治愈音频类型
enum HealingAudioType {
    case rain
    case forest
    case piano
}
