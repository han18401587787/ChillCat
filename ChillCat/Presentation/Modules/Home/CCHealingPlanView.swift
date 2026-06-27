import Combine
import SwiftUI

// MARK: - HealingPlanView v3.0
/// 稳情计划练习页
/// 包含：步骤引导、呼吸动画（4-7-8呼吸法）、白噪音播放、练习评分、免责声明

struct CCHealingPlanView: View {
    @StateObject private var viewModel = HealingPlanViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showInterruptAlert = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部进度
                progressHeader
                
                // 步骤内容
                TabView(selection: $viewModel.currentStep) {
                    StepIntroView(nextAction: { viewModel.advanceStep() })
                        .tag(0)
                    
                    StepBreathingView(
                        viewModel: viewModel,
                        nextAction: { viewModel.advanceStep() }
                    )
                    .tag(1)
                    
                    StepWhiteNoiseView(
                        viewModel: viewModel,
                        nextAction: { viewModel.advanceStep() }
                    )
                    .tag(2)
                    
                    StepRatingView(
                        viewModel: viewModel,
                        dismissAction: { dismiss() }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
        .navigationTitle("稳情练习")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isInProgress)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isInProgress {
                    Button("退出") {
                        showInterruptAlert = true
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .alert("确定要退出吗？", isPresented: $showInterruptAlert) {
            Button("继续练习", role: .cancel) {}
            Button("退出", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("退出后本次练习进度将不会保存")
        }
        .onDisappear {
            viewModel.stopWhiteNoise()
        }
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(0..<4) { index in
                    Capsule()
                        .fill(
                            index <= viewModel.currentStep
                                ? AppTheme.accentMint
                                : AppTheme.border
                        )
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            
            Text(stepTitle)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.bottom, AppSpacing.md)
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case 0: return "第1步：了解练习"
        case 1: return "第2步：呼吸练习"
        case 2: return "第3步：白噪音放松"
        case 3: return "完成练习"
        default: return ""
        }
    }
}

// MARK: - Step 0: Intro
struct StepIntroView: View {
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            // 图标
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.accentMint.opacity(0.2), AppTheme.accentMint.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Image(systemName: "lungs.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.accentMint, AppTheme.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: AppSpacing.md) {
                Text("稳情练习")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("通过4-7-8呼吸法和白噪音\n帮助你缓解焦虑、稳定情绪")
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                StepInfoRow(
                    icon: "1.circle.fill",
                    title: "呼吸练习",
                    description: "跟随引导进行4-7-8呼吸法",
                    color: AppTheme.accentMint
                )
                
                StepInfoRow(
                    icon: "2.circle.fill",
                    title: "白噪音放松",
                    description: "选择你喜欢的自然声音",
                    color: AppTheme.softPurple
                )
                
                StepInfoRow(
                    icon: "3.circle.fill",
                    title: "练习评分",
                    description: "记录练习后的感受",
                    color: AppTheme.warmGlow
                )
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            
            Spacer()
            
            // 免责声明
            Text("本练习仅供参考，不能替代专业心理治疗")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.bottom, AppSpacing.md)
            
            Button {
                nextAction()
            } label: {
                HStack {
                    Text("开始练习")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(ComponentStyles.PrimaryButtonStyle())
            .padding(.horizontal, AppSpacing.xxxl)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Step Info Row
struct StepInfoRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Step 1: Breathing
struct StepBreathingView: View {
    @ObservedObject var viewModel: HealingPlanViewModel
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // 呼吸动画
            VStack(spacing: AppSpacing.xxl) {
                ZStack {
                    // 外层光环
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.accentMint.opacity(0.3), AppTheme.softPurple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(viewModel.breathScale * 1.15)
                        .opacity(viewModel.breathOpacity * 0.4)
                        .animation(.easeInOut(duration: viewModel.currentPhaseDuration), value: viewModel.breathScale)
                    
                    // 主呼吸圆
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    viewModel.currentPhaseColor.opacity(0.4),
                                    viewModel.currentPhaseColor.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(viewModel.breathScale)
                        .opacity(viewModel.breathOpacity)
                        .animation(.easeInOut(duration: viewModel.currentPhaseDuration), value: viewModel.breathScale)
                    
                    // 中心文字
                    VStack(spacing: AppSpacing.sm) {
                        Text(viewModel.currentPhaseText)
                            .font(AppFont.title1)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(viewModel.phaseCountdownText)
                            .font(AppFont.largeTitle)
                            .foregroundColor(viewModel.currentPhaseColor)
                            .monospacedDigit()
                        
                        Text("\(viewModel.completedCycles)/\(viewModel.totalCycles) 轮")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
                
                // 呼吸指导文字
                Text(viewModel.currentPhaseInstruction)
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // 免责声明
            Text("如有任何身体不适，请立即停止练习")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textTertiary)
                .padding(.bottom, AppSpacing.md)
            
            // 按钮区域
            VStack(spacing: AppSpacing.md) {
                if viewModel.isBreathingCompleted {
                    Button {
                        nextAction()
                    } label: {
                        HStack {
                            Text("继续下一步")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(ComponentStyles.PrimaryButtonStyle())
                } else if viewModel.isBreathingActive {
                    Button {
                        viewModel.resetBreathing()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重新开始")
                        }
                    }
                    .buttonStyle(ComponentStyles.SecondaryButtonStyle())
                } else {
                    Button {
                        viewModel.startBreathing()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("开始呼吸练习")
                        }
                    }
                    .buttonStyle(ComponentStyles.PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, AppSpacing.xxxl)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Step 2: White Noise
struct StepWhiteNoiseView: View {
    @ObservedObject var viewModel: HealingPlanViewModel
    let nextAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            // 白噪音图标动画
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                viewModel.selectedWhiteNoise.color.opacity(viewModel.isWhiteNoisePlaying ? 0.2 : 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                
                Image(systemName: viewModel.selectedWhiteNoise.sfSymbol)
                    .font(.system(size: 48))
                    .foregroundColor(viewModel.selectedWhiteNoise.color)
                    .scaleEffect(viewModel.isWhiteNoisePlaying ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: viewModel.isWhiteNoisePlaying
                    )
                
                // 播放波纹
                if viewModel.isWhiteNoisePlaying {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(viewModel.selectedWhiteNoise.color.opacity(0.2), lineWidth: 1)
                            .frame(width: 180 + CGFloat(index) * 40, height: 180 + CGFloat(index) * 40)
                            .scaleEffect(viewModel.whiteNoiseRipple ? 1.2 : 0.9)
                            .opacity(viewModel.whiteNoiseRipple ? 0 : 0.4)
                            .animation(
                                .easeOut(duration: 2.0).repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.6),
                                value: viewModel.whiteNoiseRipple
                            )
                    }
                }
            }
            
            VStack(spacing: AppSpacing.md) {
                Text(viewModel.selectedWhiteNoise.name)
                    .font(AppFont.title2)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(viewModel.isWhiteNoisePlaying ? "正在播放..." : "点击播放放松")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // 白噪音选择
            HStack(spacing: AppSpacing.lg) {
                ForEach(WhiteNoiseOption.allCases, id: \.self) { option in
                    Button {
                        viewModel.selectWhiteNoise(option)
                    } label: {
                        VStack(spacing: AppSpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(
                                        viewModel.selectedWhiteNoise == option
                                            ? option.color.opacity(0.15)
                                            : AppTheme.backgroundSecondary
                                    )
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: option.sfSymbol)
                                    .font(.system(size: 24))
                                    .foregroundColor(
                                        viewModel.selectedWhiteNoise == option
                                            ? option.color
                                            : AppTheme.textTertiary
                                    )
                            }
                            
                            Text(option.name)
                                .font(AppFont.footnote)
                                .foregroundColor(
                                    viewModel.selectedWhiteNoise == option
                                        ? AppTheme.textPrimary
                                        : AppTheme.textTertiary
                                )
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            
            Spacer()
            
            Button {
                viewModel.stopWhiteNoise()
                nextAction()
            } label: {
                HStack {
                    Text("完成放松")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(ComponentStyles.PrimaryButtonStyle())
            .padding(.horizontal, AppSpacing.xxxl)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Step 3: Rating
struct StepRatingView: View {
    @ObservedObject var viewModel: HealingPlanViewModel
    let dismissAction: () -> Void
    
    @State private var showCompletionAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                Spacer(minLength: 40)
                
                // 完成图标
                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppTheme.safeGreen.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        if showCompletionAnimation {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.safeGreen)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Text("练习完成")
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("你今天做得很好\n给这次练习打个分吧")
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                
                // 评分区域
                VStack(spacing: AppSpacing.md) {
                    Text("你的感受如何？")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: AppSpacing.lg) {
                        ForEach(1...5, id: \.self) { rating in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    viewModel.selectedRating = rating
                                }
                            } label: {
                                VStack(spacing: AppSpacing.xs) {
                                    Image(systemName: rating <= viewModel.selectedRating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(
                                            rating <= viewModel.selectedRating
                                                ? AppTheme.warmGlow
                                                : AppTheme.textTertiary.opacity(0.3)
                                        )
                                        .scaleEffect(rating == viewModel.selectedRating ? 1.2 : 1.0)
                                    
                                    Text(ratingText(rating))
                                        .font(AppFont.caption2)
                                        .foregroundColor(
                                            rating == viewModel.selectedRating
                                                ? AppTheme.textPrimary
                                                : AppTheme.textTertiary
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(AppSpacing.xl)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
                
                // 免责声明
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text("本练习仅供参考，不能替代专业心理治疗\n如情绪持续低落，建议寻求专业帮助")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding()
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                
                Spacer(minLength: 20)
                
                // 完成按钮
                Button {
                    dismissAction()
                } label: {
                    HStack {
                        Text("完成")
                        Image(systemName: "checkmark")
                    }
                }
                .buttonStyle(ComponentStyles.PrimaryButtonStyle())
                .padding(.horizontal, AppSpacing.xxxl)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                showCompletionAnimation = true
            }
        }
    }
    
    private func ratingText(_ rating: Int) -> String {
        switch rating {
        case 1: return "更糟了"
        case 2: return "没什么变化"
        case 3: return "一般"
        case 4: return "好多了"
        case 5: return "非常好"
        default: return ""
        }
    }
}

// MARK: - White Noise Option
enum WhiteNoiseOption: String, CaseIterable {
    case rain
    case ocean
    case forest
    
    var name: String {
        switch self {
        case .rain: return "雨声"
        case .ocean: return "海浪"
        case .forest: return "森林"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "water.waves"
        case .forest: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .rain: return AppTheme.accentMint
        case .ocean: return AppTheme.primary
        case .forest: return AppTheme.safeGreen
        }
    }
}

// MARK: - ViewModel
@MainActor
final class HealingPlanViewModel: ObservableObject {
    // 步骤
    @Published var currentStep: Int = 0
    @Published var isInProgress: Bool = false
    
    // 呼吸动画
    @Published var breathScale: CGFloat = 1.0
    @Published var breathOpacity: Double = 0.5
    @Published var currentBreathingPhase: BreathingPhase = .inhale
    @Published var completedCycles: Int = 0
    @Published var phaseCountdown: Int = 4
    @Published var isBreathingActive: Bool = false
    @Published var isBreathingCompleted: Bool = false
    
    let totalCycles: Int = 3
    
    // 白噪音
    @Published var selectedWhiteNoise: WhiteNoiseOption = .rain
    @Published var isWhiteNoisePlaying: Bool = false
    @Published var whiteNoiseRipple: Bool = false
    
    // 评分
    @Published var selectedRating: Int = 0
    
    // 定时器
    private var phaseTimer: Timer?
    private var countdownTimer: Timer?
    
    var currentPhaseText: String {
        switch currentBreathingPhase {
        case .inhale: return "吸气"
        case .hold: return "屏息"
        case .exhale: return "呼气"
        }
    }
    
    var currentPhaseColor: Color {
        switch currentBreathingPhase {
        case .inhale: return AppTheme.accentMint
        case .hold: return AppTheme.softPurple
        case .exhale: return AppTheme.safeGreen
        }
    }
    
    var currentPhaseInstruction: String {
        switch currentBreathingPhase {
        case .inhale: return "用鼻子缓慢吸气，感受腹部缓缓鼓起"
        case .hold: return "轻轻屏住呼吸，保持放松"
        case .exhale: return "用嘴巴缓慢呼气，感受身体渐渐放松"
        }
    }
    
    var phaseCountdownText: String {
        "\(phaseCountdown)"
    }
    
    var currentPhaseDuration: TimeInterval {
        switch currentBreathingPhase {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        }
    }
    
    func advanceStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
            if currentStep >= 1 {
                isInProgress = true
            }
        }
    }
    
    // MARK: - Breathing
    func startBreathing() {
        isBreathingActive = true
        isBreathingCompleted = false
        completedCycles = 0
        startBreathingCycle()
    }
    
    func resetBreathing() {
        stopTimers()
        isBreathingActive = false
        isBreathingCompleted = false
        completedCycles = 0
        currentBreathingPhase = .inhale
        breathScale = 1.0
        breathOpacity = 0.5
    }
    
    private func startBreathingCycle() {
        guard isBreathingActive else { return }
        performPhase(.inhale)
    }
    
    private func performPhase(_ phase: BreathingPhase) {
        currentBreathingPhase = phase
        
        switch phase {
        case .inhale:
            phaseCountdown = 4
            withAnimation(.easeInOut(duration: 4.0)) {
                breathScale = 1.3
                breathOpacity = 0.8
            }
            startCountdown(from: 4) { [weak self] in
                self?.performPhase(.hold)
            }
            
        case .hold:
            phaseCountdown = 7
            startCountdown(from: 7) { [weak self] in
                self?.performPhase(.exhale)
            }
            
        case .exhale:
            phaseCountdown = 8
            withAnimation(.easeInOut(duration: 8.0)) {
                breathScale = 1.0
                breathOpacity = 0.4
            }
            startCountdown(from: 8) { [weak self] in
                guard let self = self else { return }
                self.completedCycles += 1
                if self.completedCycles >= self.totalCycles {
                    self.isBreathingActive = false
                    self.isBreathingCompleted = true
                } else {
                    self.performPhase(.inhale)
                }
            }
        }
    }
    
    private func startCountdown(from: Int, onComplete: @escaping () -> Void) {
        countdownTimer?.invalidate()
        phaseCountdown = from
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.phaseCountdown > 1 {
                self.phaseCountdown -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
    
    private func stopTimers() {
        phaseTimer?.invalidate()
        countdownTimer?.invalidate()
        phaseTimer = nil
        countdownTimer = nil
    }
    
    // MARK: - White Noise
    func selectWhiteNoise(_ option: WhiteNoiseOption) {
        selectedWhiteNoise = option
        if isWhiteNoisePlaying {
            stopWhiteNoise()
            startWhiteNoise()
        }
    }
    
    func startWhiteNoise() {
        isWhiteNoisePlaying = true
        whiteNoiseRipple = true
    }
    
    func stopWhiteNoise() {
        isWhiteNoisePlaying = false
        whiteNoiseRipple = false
    }
    
    deinit {
        MainActor.assumeIsolated {
            stopTimers()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCHealingPlanView()
    }
}
