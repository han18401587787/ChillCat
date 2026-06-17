import SwiftUI

// MARK: - ComponentStyles v3.0
/// 组件样式系统 - v3.0新增12个组件样式Token
enum ComponentStyles {
    // MARK: - 按钮样式
    
    /// 主要按钮
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFont.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    /// 次要按钮
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFont.bodyBold)
                .foregroundColor(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(AppTheme.primary, lineWidth: 1.5)
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    /// 发布按钮（突出样式）
    struct PublishButtonStyle: ButtonStyle {
        let size: CGFloat
        
        init(size: CGFloat = 56) {
            self.size = size
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: AppTheme.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
    
    /// 文字按钮
    struct TextButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFont.bodyBold)
                .foregroundColor(AppTheme.primary)
                .opacity(configuration.isPressed ? 0.6 : 1.0)
        }
    }
    
    // MARK: - 卡片样式
    
    /// 基础卡片
    struct Card: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppSpacing.lg)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
    
    /// 情绪卡片
    struct EmotionCard: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .padding(AppSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - 输入框样式
    
    /// 基础输入框
    struct InputField: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.body)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
    
    /// 搜索框
    struct SearchField: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.body)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.full))
        }
    }
    
    // MARK: - 标签样式
    
    /// 状态标签
    struct StatusTag: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(AppFont.footnote)
                .foregroundColor(color)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(color.opacity(0.1))
                .clipShape(Capsule())
        }
    }
    
    /// 情绪标签
    struct EmotionTag: ViewModifier {
        let color: Color
        
        func body(content: Content) -> some View {
            content
                .font(AppFont.caption)
                .foregroundColor(color)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.full))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.full)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - 列表样式
    
    /// 设置项行
    struct SettingsRow: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.vertical, AppSpacing.md)
                .padding(.horizontal, AppSpacing.lg)
                .background(AppTheme.surface)
        }
    }
    
    /// 分组区域
    struct SectionGroup: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppSpacing.lg)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
    }
    
    // MARK: - 进度/指示器样式
    
    /// 情绪强度条
    struct IntensityBar: View {
        let value: Double
        let color: Color
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
    
    /// 脉搏动画指示器
    struct PulseIndicator: View {
        let color: Color
        
        @State private var isAnimating = false
        
        var body: some View {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .scaleEffect(isAnimating ? 1.5 : 1.0)
                .opacity(isAnimating ? 0.3 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        }
    }
    
    // MARK: - 装饰元素
    
    /// 渐变背景
    struct GradientBackground: View {
        let colors: [Color]
        
        var body: some View {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    /// 玻璃效果
    struct GlassEffect: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
    }
}

// MARK: - View Extensions for ComponentStyles

extension View {
    func cardStyle() -> some View {
        modifier(ComponentStyles.Card())
    }
    
    func emotionCard(color: Color) -> some View {
        modifier(ComponentStyles.EmotionCard(color: color))
    }
    
    func inputField() -> some View {
        modifier(ComponentStyles.InputField())
    }
    
    func searchField() -> some View {
        modifier(ComponentStyles.SearchField())
    }
    
    func statusTag(color: Color) -> some View {
        modifier(ComponentStyles.StatusTag(color: color))
    }
    
    func emotionTag(color: Color) -> some View {
        modifier(ComponentStyles.EmotionTag(color: color))
    }
    
    func settingsRow() -> some View {
        modifier(ComponentStyles.SettingsRow())
    }
    
    func sectionGroup() -> some View {
        modifier(ComponentStyles.SectionGroup())
    }
    
    func glassEffect() -> some View {
        modifier(ComponentStyles.GlassEffect())
    }
}
