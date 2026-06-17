import SwiftUI

// MARK: - HealingAnimation v3.0
/// 治愈系动效组件
/// 包含：共鸣波纹动效、呼吸动画、打卡完成动效

// MARK: - Resonance Ripple Animation
/// 共鸣波纹动效：屏幕边缘泛起暖光波纹，两束光汇聚中心
struct ResonanceRippleView: View {
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0.8
    @State private var centerGlow: Double = 0.0
    @State private var isAnimating: Bool = false

    let size: CGFloat
    let primaryColor: Color
    let secondaryColor: Color

    init(
        size: CGFloat = 200,
        primaryColor: Color = AppTheme.warmGlow,
        secondaryColor: Color = AppTheme.roseGold
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    var body: some View {
        ZStack {
            // 外层波纹
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.4), secondaryColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size * rippleScale * (1 + CGFloat(index) * 0.3),
                           height: size * rippleScale * (1 + CGFloat(index) * 0.3))
                    .opacity(rippleOpacity * (1 - Double(index) * 0.25))
                    .blur(radius: 4)
            }

            // 中心光点
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(centerGlow),
                            primaryColor.opacity(centerGlow * 0.5),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size, height: size)
        }
        .onAppear {
            startAnimation()
        }
    }

    func startAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            rippleScale = 1.0
            rippleOpacity = 0.2
            centerGlow = 0.6
        }
    }
}

// MARK: - Breathing Animation
/// 呼吸动画：用于稳情计划呼吸练习
struct BreathingAnimationView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.4
    @State private var phase: BreathingPhase = .inhale
    @State private var cycleCount: Int = 0

    let size: CGFloat
    let color: Color
    let duration: TimeInterval
    let targetCycles: Int
    let onPhaseChange: ((BreathingPhase, Int) -> Void)?
    let onComplete: (() -> Void)?

    init(
        size: CGFloat = 200,
        color: Color = AppTheme.calmBlue,
        duration: TimeInterval = 4.0,
        targetCycles: Int = 5,
        onPhaseChange: ((BreathingPhase, Int) -> Void)? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.size = size
        self.color = color
        self.duration = duration
        self.targetCycles = targetCycles
        self.onPhaseChange = onPhaseChange
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            ZStack {
                // 外层光环
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 2)
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(scale * 1.1)
                    .opacity(opacity * 0.5)

                // 主圆
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // 引导文字
                VStack(spacing: AppSpacing.sm) {
                    Text(phaseText)
                        .font(AppFont.title2)
                        .foregroundColor(AppTheme.textPrimary)

                    if targetCycles > 1 {
                        Text("\(min(cycleCount, targetCycles))/\(targetCycles)")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
            }

            // 呼吸指示条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(
                            width: geometry.size.width * breathProgress,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            .padding(.horizontal, AppSpacing.xl)
        }
        .onAppear {
            startBreathingCycle()
        }
    }

    private var phaseText: String {
        switch phase {
        case .inhale: return "吸气"
        case .hold: return "屏息"
        case .exhale: return "呼气"
        }
    }

    private var breathProgress: CGFloat {
        switch phase {
        case .inhale: return scale
        case .hold: return 1.0
        case .exhale: return scale
        }
    }

    private func startBreathingCycle() {
        performPhase(.inhale)
    }

    private func performPhase(_ phase: BreathingPhase) {
        self.phase = phase
        onPhaseChange?(phase, cycleCount)

        let halfDuration = duration / 2

        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: halfDuration)) {
                scale = 1.3
                opacity = 0.8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration) {
                performPhase(.hold)
            }

        case .hold:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                performPhase(.exhale)
            }

        case .exhale:
            withAnimation(.easeInOut(duration: halfDuration)) {
                scale = 1.0
                opacity = 0.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration) {
                cycleCount += 1
                if cycleCount >= targetCycles {
                    onComplete?()
                } else {
                    performPhase(.inhale)
                }
            }
        }
    }
}

enum BreathingPhase {
    case inhale
    case hold
    case exhale
}

// MARK: - Checkin Complete Animation
/// 打卡完成动效：粒子绽放 + 对勾
struct CheckinCompleteAnimation: View {
    @State private var showCheckmark: Bool = false
    @State private var particles: [Particle] = []
    @State private var ringScale: CGFloat = 0.0
    @State private var ringOpacity: Double = 1.0

    let size: CGFloat
    let color: Color
    let onComplete: (() -> Void)?

    init(
        size: CGFloat = 120,
        color: Color = AppTheme.safeGreen,
        onComplete: (() -> Void)? = nil
    ) {
        self.size = size
        self.color = color
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            // 粒子
            ForEach(particles) { particle in
                Circle()
                    .fill(particleColor(particle))
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }

            // 光环
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 3)
                .frame(width: size * ringScale, height: size * ringScale)
                .opacity(ringOpacity)

            // 圆形背景
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.2), color.opacity(0.05)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)

            // 对勾
            if showCheckmark {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(color)
                    .scaleEffect(showCheckmark ? 1.0 : 0.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showCheckmark)
            }
        }
        .frame(width: size * 1.5, height: size * 1.5)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // 光环扩散
        withAnimation(.easeOut(duration: 0.8)) {
            ringScale = 1.3
            ringOpacity = 0.0
        }

        // 粒子生成
        for i in 0..<20 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 20...size * 0.8)
            let particle = Particle(
                id: UUID().uuidString,
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                size: CGFloat.random(in: 3...8),
                opacity: 0.8,
                colorIndex: i % 4
            )
            particles.append(particle)

            withAnimation(.easeOut(duration: 0.6).delay(Double.random(in: 0...0.3))) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].x *= 1.8
                    particles[index].y *= 1.8
                    particles[index].opacity = 0.0
                }
            }
        }

        // 对勾出现
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCheckmark = true
        }

        // 完成回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onComplete?()
        }
    }

    private func particleColor(_ particle: Particle) -> Color {
        let colors: [Color] = [
            color,
            AppTheme.warmGlow,
            AppTheme.roseGold,
            AppTheme.hopeCyan
        ]
        return colors[particle.colorIndex % colors.count]
    }
}

struct Particle: Identifiable {
    let id: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    let colorIndex: Int
}

// MARK: - Healing Pulse Animation
/// 治愈脉冲动画：温和的心跳式脉动
struct HealingPulseView: View {
    @State private var isAnimating: Bool = false

    let color: Color
    let size: CGFloat

    init(color: Color = AppTheme.softPurple, size: CGFloat = 60) {
        self.color = color
        self.size = size
    }

    var body: some View {
        ZStack {
            ForEach(0..<2) { index in
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(isAnimating ? 1.4 + CGFloat(index) * 0.3 : 0.8)
                    .opacity(isAnimating ? 0.0 : 0.6)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.5),
                        value: isAnimating
                    )
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0.1)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Composite: Full Healing Overlay
/// 完整治愈动效叠加层（用于打卡成功等场景）
struct HealingOverlayView: View {
    @Binding var isPresented: Bool
    let title: String
    let subtitle: String

    @State private var showContent: Bool = false

    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: AppSpacing.xl) {
                // 共鸣波纹
                ResonanceRippleView(size: 120)

                // 打卡完成动画
                CheckinCompleteAnimation(size: 100)

                // 文字
                VStack(spacing: AppSpacing.sm) {
                    Text(title)
                        .font(AppFont.title2)
                        .foregroundColor(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .padding(AppSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppTheme.surface)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
            )
            .padding(AppSpacing.xl)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }

            // 自动消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ResonanceRippleView(size: 120)

        BreathingAnimationView(size: 150, targetCycles: 3)

        CheckinCompleteAnimation(size: 100)

        HealingPulseView()
    }
    .padding()
    .background(AppTheme.background)
}
