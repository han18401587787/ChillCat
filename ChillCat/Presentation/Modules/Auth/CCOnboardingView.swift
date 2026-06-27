import Combine
import SwiftUI

// MARK: - OnboardingView v3.0
/// 新用户引导流程
/// 包含：3屏欢迎引导 + 初始评估(PHQ-9/GAD-7简版) + 偏好设置

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: OnboardingPage = .welcome
    
    var body: some View {
        ZStack {
            Color.xuanApricotBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 进度指示
                if currentPage != .welcome {
                    progressBar
                }
                
                // 页面内容
                Group {
                    switch currentPage {
                    case .welcome:
                        welcomePages
                    case .assessment:
                        assessmentPage
                    case .preferences:
                        preferencesPage
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.35), value: currentPage)
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: XuanSpacing.sm) {
            ForEach(OnboardingPage.allCases.filter { $0 != .welcome }, id: \.self) { page in
                Capsule()
                    .fill(
                        page == currentPage || OnboardingPage.allCases.firstIndex(of: page)! < OnboardingPage.allCases.firstIndex(of: currentPage)!
                            ? Color.xuanApricot
                            : Color.xuanBorder
                    )
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, XuanSpacing.lg)
        .padding(.vertical, XuanSpacing.md)
    }
    
    // MARK: - Welcome Pages
    private var welcomePages: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.welcomePageIndex) {
                // 第1屏：品牌slogan
                welcomeScreen1
                    .tag(0)
                
                // 第2屏：核心功能
                welcomeScreen2
                    .tag(1)
                
                // 第3屏：隐私承诺
                welcomeScreen3
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // 指示器
            pageIndicator
            
            // 按钮
            VStack(spacing: XuanSpacing.md) {
                Button {
                    if viewModel.welcomePageIndex < 2 {
                        withAnimation { viewModel.welcomePageIndex += 1 }
                    } else {
                        withAnimation { currentPage = .assessment }
                    }
                } label: {
                    Text(viewModel.welcomePageIndex < 2 ? "继续" : "开始评估")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.xuanApricot)
                        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
                }
                .padding(.horizontal, XuanSpacing.xl3)
                
                if viewModel.welcomePageIndex < 2 {
                    Button("跳过") {
                        withAnimation { currentPage = .assessment }
                    }
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Screen 1: Brand Slogan
    private var welcomeScreen1: some View {
        VStack(spacing: XuanSpacing.xl2) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.xuanApricot.opacity(0.15), Color.xuanInfo.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                
                VStack(spacing: XuanSpacing.md) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.xuanApricot, Color.xuanPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("绪安")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color.xuanTextPrimary)
                }
            }
            
            VStack(spacing: XuanSpacing.md) {
                Text("\"接住所有情绪\"")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)
                
                Text("你的AI情绪陪伴伙伴\n24小时守护你的心理健康")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            
            Spacer()
        }
        .padding(.horizontal, XuanSpacing.xl3)
    }
    
    // MARK: - Screen 2: Features
    private var welcomeScreen2: some View {
        VStack(spacing: XuanSpacing.xl3) {
            Spacer()
            
            VStack(spacing: XuanSpacing.lg) {
                Text("核心功能")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)
                
                VStack(spacing: XuanSpacing.lg) {
                    FeatureIntroRow(
                        icon: "brain.head.profile",
                        title: "AI倾听官",
                        description: "24小时在线的AI倾听伙伴\n随时与你对话",
                        color: Color.xuanTextSecondary
                    )
                    
                    FeatureIntroRow(
                        icon: "waveform.circle.fill",
                        title: "共鸣墙",
                        description: "匿名分享情绪，找到\n与你感同身受的人",
                        color: Color.xuanApricot
                    )
                    
                    FeatureIntroRow(
                        icon: "heart.circle.fill",
                        title: "鼓励链",
                        description: "传递温暖，一句鼓励\n就能照亮他人的世界",
                        color: Color.xuanApricotDark
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, XuanSpacing.xl3)
    }
    
    // MARK: - Screen 3: Privacy
    private var welcomeScreen3: some View {
        VStack(spacing: XuanSpacing.xl2) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.xuanSuccess.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.xuanSuccess)
            }
            
            VStack(spacing: XuanSpacing.md) {
                Text("你的隐私，我们守护")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)
                
                VStack(alignment: .leading, spacing: XuanSpacing.lg) {
                    PrivacyPointRow(
                        icon: "lock.fill",
                        text: "所有数据加密存储，只有你能访问"
                    )
                    
                    PrivacyPointRow(
                        icon: "eye.slash.fill",
                        text: "匿名功能保护你的身份信息"
                    )
                    
                    PrivacyPointRow(
                        icon: "hand.raised.fill",
                        text: "你的数据不会被分享给第三方"
                    )
                    
                    PrivacyPointRow(
                        icon: "trash.fill",
                        text: "你可以随时删除所有数据"
                    )
                }
                .padding(XuanSpacing.xl)
                .background(Color.xuanSurface)
                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            }
            
            Spacer()
        }
        .padding(.horizontal, XuanSpacing.xl3)
    }
    
    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: XuanSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        index == viewModel.welcomePageIndex
                            ? Color.xuanApricot
                            : Color.xuanTextTertiary.opacity(0.3)
                    )
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut, value: viewModel.welcomePageIndex)
            }
        }
        .padding(.vertical, XuanSpacing.xl)
    }
    
    // MARK: - Assessment Page (PHQ-9/GAD-7 简版)
    private var assessmentPage: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl) {
                VStack(spacing: XuanSpacing.md) {
                    Text("初始评估")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("帮助我们更好地了解你的状态\n（可跳过）")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, XuanSpacing.xl3)
                
                // 评估问题
                VStack(spacing: XuanSpacing.lg) {
                    ForEach(Array(viewModel.assessmentQuestions.enumerated()), id: \.offset) { index, question in
                        AssessmentQuestionCard(
                            question: question,
                            selectedAnswer: $viewModel.assessmentAnswers[index],
                            index: index
                        )
                    }
                }
                
                // 按钮
                VStack(spacing: XuanSpacing.md) {
                    Button {
                        withAnimation { currentPage = .preferences }
                    } label: {
                        Text("下一步")
                            .font(XuanFont.bodyLBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.xuanApricot)
                            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
                    }
                    
                    Button("跳过评估") {
                        withAnimation { currentPage = .preferences }
                    }
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                }
                .padding(.horizontal, XuanSpacing.xl3)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, XuanSpacing.lg)
        }
    }
    
    // MARK: - Preferences Page
    private var preferencesPage: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl) {
                VStack(spacing: XuanSpacing.md) {
                    Text("偏好设置")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("个性化你的绪安体验")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .padding(.top, XuanSpacing.xl3)
                
                // 关注的情绪类型
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    Text("你更关注哪些情绪？")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: XuanSpacing.sm) {
                        ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                            Button {
                                viewModel.toggleEmotionFocus(emotion.chinese)
                            } label: {
                                HStack(spacing: XuanSpacing.sm) {
                                    Image(systemName: emotion.sfSymbol)
                                        .font(.system(size: 14))
                                    
                                    Text(emotion.chinese)
                                        .font(XuanFont.bodyS)
                                }
                                .foregroundColor(
                                    viewModel.selectedEmotions.contains(emotion.chinese)
                                        ? .white
                                        : emotion.color
                                )
                                .padding(.horizontal, XuanSpacing.md)
                                .padding(.vertical, XuanSpacing.sm)
                                .frame(maxWidth: .infinity)
                                .background(
                                    viewModel.selectedEmotions.contains(emotion.chinese)
                                        ? emotion.color
                                        : emotion.color.opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
                            }
                        }
                    }
                }
                .sectionGroup()
                
                // 提醒时间
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    Text("提醒时间")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    HStack(spacing: XuanSpacing.md) {
                        ForEach(viewModel.reminderTimeOptions, id: \.self) { time in
                            Button {
                                viewModel.selectedReminderTime = time
                            } label: {
                                Text(time)
                                    .font(XuanFont.bodyS)
                                    .foregroundColor(
                                        viewModel.selectedReminderTime == time
                                            ? .white
                                            : Color.xuanTextSecondary
                                    )
                                    .padding(.horizontal, XuanSpacing.lg)
                                    .padding(.vertical, XuanSpacing.sm)
                                    .background(
                                        viewModel.selectedReminderTime == time
                                            ? Color.xuanApricot
                                            : Color.xuanSurface
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .sectionGroup()
                
                // 日记偏好
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    Text("日记偏好")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    VStack(spacing: XuanSpacing.md) {
                        PreferenceToggle(
                            icon: "mic.fill",
                            title: "语音记录",
                            subtitle: "通过语音快速记录情绪",
                            isOn: $viewModel.preferVoice
                        )
                        
                        PreferenceToggle(
                            icon: "pencil.line",
                            title: "文字记录",
                            subtitle: "通过文字详细记录",
                            isOn: $viewModel.preferText
                        )
                        
                        PreferenceToggle(
                            icon: "bell.fill",
                            title: "每日提醒",
                            subtitle: "每天在设定时间提醒打卡",
                            isOn: $viewModel.enableReminder
                        )
                    }
                }
                .sectionGroup()
                
                // 免责声明
                Text("绪安不是医疗设备，不能替代专业心理治疗。\n如有严重情绪困扰，请寻求专业帮助。")
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, XuanSpacing.xl)
                
                // 完成按钮
                Button {
                    dismiss()
                } label: {
                    Text("开始使用绪安")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.xuanApricot)
                        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
                }
                .padding(.horizontal, XuanSpacing.xl3)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, XuanSpacing.lg)
        }
    }
}

// MARK: - Feature Intro Row
struct FeatureIntroRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: XuanSpacing.lg) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanTextPrimary)
                
                Text(description)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
    }
}

// MARK: - Privacy Point Row
struct PrivacyPointRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.xuanSuccess)
                .frame(width: 24)
            
            Text(text)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextPrimary)
        }
    }
}

// MARK: - Assessment Question Card
struct AssessmentQuestionCard: View {
    let question: AssessmentQuestion
    @Binding var selectedAnswer: Int
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("\(index + 1). \(question.text)")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)
            
            HStack(spacing: XuanSpacing.sm) {
                ForEach(0..<question.options.count, id: \.self) { i in
                    Button {
                        selectedAnswer = i
                    } label: {
                        VStack(spacing: 4) {
                            Text(question.options[i])
                                .font(.system(size: 22))
                            
                            Text(question.optionLabels[i])
                                .font(.system(size: 9))
                                .foregroundColor(Color.xuanTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.sm)
                        .background(
                            selectedAnswer == i
                                ? Color.xuanApricot.opacity(0.15)
                                : Color.xuanSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: XuanRadius.sm)
                                .stroke(
                                    selectedAnswer == i
                                        ? Color.xuanApricot.opacity(0.5)
                                        : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Preference Toggle
struct PreferenceToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.xuanApricot)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
                
                Text(subtitle)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.xuanApricot)
        }
    }
}

// MARK: - Onboarding Page Enum
enum OnboardingPage: CaseIterable {
    case welcome
    case assessment
    case preferences
}

// MARK: - Assessment Question Model
struct AssessmentQuestion {
    let text: String
    let options: [String]
    let optionLabels: [String]
}

// MARK: - ViewModel
@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var welcomePageIndex: Int = 0
    @Published var assessmentAnswers: [Int] = [2, 2, 2, 2, 2, 2]
    @Published var selectedEmotions: [String] = ["焦虑", "平静", "希望"]
    @Published var selectedReminderTime: String = "晚上 21:00"
    @Published var preferVoice: Bool = true
    @Published var preferText: Bool = true
    @Published var enableReminder: Bool = true
    
    let reminderTimeOptions = ["早上 8:00", "中午 12:00", "晚上 21:00", "不提醒"]
    
    let assessmentQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(
            text: "最近两周，你感到情绪低落、沮丧或绝望的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
        AssessmentQuestion(
            text: "最近两周，你对做事缺乏兴趣或乐趣的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
        AssessmentQuestion(
            text: "最近两周，你感到紧张、焦虑或不安的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
        AssessmentQuestion(
            text: "最近两周，你难以入睡或睡得过多的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
        AssessmentQuestion(
            text: "最近两周，你感到疲劳或精力不足的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
        AssessmentQuestion(
            text: "最近两周，你难以集中注意力的频率是？",
            options: ["😊", "🙂", "😐", "😔", "😢"],
            optionLabels: ["从不", "几天", "一半以上", "几乎每天", "每天"]
        ),
    ]
    
    func toggleEmotionFocus(_ emotion: String) {
        if selectedEmotions.contains(emotion) {
            selectedEmotions.removeAll { $0 == emotion }
        } else {
            selectedEmotions.append(emotion)
        }
    }
}

#Preview {
    OnboardingView()
}
