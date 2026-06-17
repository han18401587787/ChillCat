//
//  CCToastView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI

enum CCToastType {
    case success
    case error
    case warning
    case info

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

struct CCToastView: View {
    let message: String
    let type: CCToastType

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: type.iconName)
                .foregroundColor(toastColor)
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.sm)
        .shadow(color: AppTheme.textMuted.opacity(0.2), radius: 4)
        .padding(.horizontal, AppSpacing.md)
    }

    private var toastColor: Color {
        switch type {
        case .success: return AppTheme.success
        case .error:   return AppTheme.error
        case .warning: return AppTheme.warm
        case .info:    return AppTheme.primary
        }
    }
}

// MARK: - Toast Modifier

struct CCToastModifier: ViewModifier {
    @Binding var message: (String, CCToastType)?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let (message, type) = message {
                    CCToastView(message: message, type: type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.message = nil
                                }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: message?.0)
    }
}

extension View {
    func cc_toast(message: Binding<(String, CCToastType)?>) -> some View {
        modifier(CCToastModifier(message: message))
    }
}
