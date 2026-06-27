import SwiftUI

// MARK: - ComponentStyles v3.0 (严格遵循 Ardot 设计标注总览)
/// 主按钮: 暖杏填充 #E8C4A3 / Pressed #C49E7D + press阴影
/// 次按钮: 浅暖杏 #F2DBC9
/// 输入框: 暖灰描边 / Focused 暖杏描边 / Error 红描边
/// Chip: 白底+薄荷绿描边 / Selected 薄荷绿填充+白字
/// 卡片: 白底+card阴影 / Pressed 暖白底+press阴影

enum ComponentStyles {
    // MARK: - 按钮样式

    /// 主按钮 (标注规范: 暖杏填充 #E8C4A3, Pressed #C49E7D+press阴影)
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFont.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    configuration.isPressed
                        ? Color(hex: "C49E7D")
                        : AppTheme.primary
                )
                .cornerRadius(AppRadius.lg)
                .shadow(
                    color: Color(hex: "2C2416").opacity(configuration.isPressed ? 0.08 : 0.06),
                    radius: configuration.isPressed ? 4 : 12,
                    x: 0,
                    y: configuration.isPressed ? 1 : 2
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    /// 次要按钮 (标注规范: 浅暖杏 #F2DBC9, Pressed 深暖杏填充+白字)
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFont.bodyBold)
                .foregroundColor(
                    configuration.isPressed
                        ? .white
                        : AppTheme.warmGold
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    configuration.isPressed
                        ? AppTheme.primaryDark
                        : Color(hex: "F2DBC9")
                )
                .cornerRadius(AppRadius.lg)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    /// 发布按钮 (突出样式)
    struct PublishButtonStyle: ButtonStyle {
        let size: CGFloat
        init(size: CGFloat = 56) { self.size = size }
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(configuration.isPressed ? Color(hex: "C49E7D") : AppTheme.primary)
                )
                .shadow(
                    color: Color(hex: "2C2416").opacity(configuration.isPressed ? 0.08 : 0.10),
                    radius: configuration.isPressed ? 4 : 24,
                    x: 0,
                    y: configuration.isPressed ? 1 : 4
                )
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

    /// 基础卡片 (标注规范: 白底+card阴影, Pressed 暖白底+press阴影)
    struct Card: ViewModifier {
        @State private var isPressed = false
        func body(content: Content) -> some View {
            content
                .padding(AppSpacing.lg)
                .background(isPressed ? Color(hex: "F5F0EB") : AppTheme.cardBackground)
                .cornerRadius(AppRadius.lg)
                .shadow(
                    color: Color(hex: "2C2416").opacity(isPressed ? 0.08 : 0.06),
                    radius: isPressed ? 4 : 12,
                    x: 0,
                    y: isPressed ? 1 : 2
                )
                .animation(.easeInOut(duration: 0.15), value: isPressed)
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
                .cornerRadius(AppRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - 输入框样式

    /// 基础输入框 (标注规范: 暖灰描边, Focused: 暖杏描边, Error: 红描边)
    struct InputField: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.body)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
    }

    /// 搜索框
    struct SearchField: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.body)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.full)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.full)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
    }

    // MARK: - 标签样式

    /// Chip 标签 (标注规范: 白底+薄荷绿描边, Selected: 薄荷绿填充+白字)
    struct ChipTag: ViewModifier {
        let color: Color
        let isSelected: Bool
        func body(content: Content) -> some View {
            content
                .font(AppFont.footnote)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(isSelected ? color : AppTheme.cardBackground)
                .cornerRadius(AppRadius.full)
                .overlay(
                    isSelected
                        ? nil
                        : RoundedRectangle(cornerRadius: AppRadius.full).stroke(color, lineWidth: 1)
                )
        }
    }

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
                .cornerRadius(AppRadius.full)
        }
    }

    // MARK: - 列表/分组样式

    struct SettingsRow: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.vertical, AppSpacing.md)
                .padding(.horizontal, AppSpacing.lg)
                .background(AppTheme.surface)
        }
    }

    struct SectionGroup: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.lg)
        }
    }

    // MARK: - 进度/指示器

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
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

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

    // MARK: - 装饰

    struct GradientBackground: View {
        let colors: [Color]
        var body: some View {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }

    struct GlassEffect: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(.ultraThinMaterial)
                .cornerRadius(AppRadius.lg)
        }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View { modifier(ComponentStyles.Card()) }
    func emotionCard(color: Color) -> some View { modifier(ComponentStyles.EmotionCard(color: color)) }
    func inputField() -> some View { modifier(ComponentStyles.InputField()) }
    func searchField() -> some View { modifier(ComponentStyles.SearchField()) }
    func statusTag(color: Color) -> some View { modifier(ComponentStyles.StatusTag(color: color)) }
    func chipTag(color: Color, isSelected: Bool) -> some View { modifier(ComponentStyles.ChipTag(color: color, isSelected: isSelected)) }
    func settingsRow() -> some View { modifier(ComponentStyles.SettingsRow()) }
    func sectionGroup() -> some View { modifier(ComponentStyles.SectionGroup()) }
    func glassEffect() -> some View { modifier(ComponentStyles.GlassEffect()) }
}
