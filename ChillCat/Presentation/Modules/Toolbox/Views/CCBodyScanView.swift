//
//  CCBodyScanView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 正念身体扫描 View
//

import SwiftUI

// MARK: - Body Scan View

struct CCBodyScanView: View {
        @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCBodyScanViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    scanContent
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "D4C8E8").opacity(0.3), Color(hex: "E8B8C8").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("正念身体扫描")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(AppTheme.primary)
            }
        }
        .onDisappear {
            if viewModel.isActive {
                viewModel.reset()
            }
        }
    }

    // MARK: - Scan Content

    private var scanContent: some View {
        VStack(spacing: AppSpacing.xl) {
            // Timer and progress
            timerSection

            // Body outline
            bodyOutlineSection

            // Current region guidance
            if viewModel.isActive {
                guidanceCard
            }

            // Settings (idle only)
            if case .idle = viewModel.phase {
                settingsCard
            }

            // Region list
            regionListSection

            // Controls
            controlButtons
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isActive ? "正在扫描" : "准备开始")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                if let region = viewModel.currentRegion, viewModel.isActive {
                    Text("\(region.name) (\(viewModel.currentRegionIndex + 1)/\(viewModel.totalRegions))")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            // Timer display
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Text(viewModel.isActive ? viewModel.formattedRemaining : viewModel.formattedTotal)
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                }
                if viewModel.isActive {
                    Text("剩余")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Body Outline

    private var bodyOutlineSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("身体地图")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                // Body outline
                bodyOutline

                // Region highlights
                ForEach(CCBodyRegion.all) { region in
                    let regionIndex = CCBodyRegion.all.firstIndex(where: { $0.id == region.id }) ?? 0
                    let isActive = regionIndex == viewModel.currentRegionIndex && viewModel.isActive
                    let isCompleted = regionIndex < viewModel.currentRegionIndex && viewModel.isActive

                    Circle()
                        .fill(
                            isActive ? region.color.opacity(0.6) :
                            (isCompleted ? Color(hex: "66BB6A").opacity(0.4) : Color.clear)
                        )
                        .frame(width: isActive ? 36 : (isCompleted ? 24 : 0))
                        .overlay(
                            Circle()
                                .stroke(
                                    isActive ? region.color : Color.clear,
                                    lineWidth: 2
                                )
                                .scaleEffect(isActive ? 1.3 : 1.0)
                                .opacity(isActive ? 1 : 0)
                                .animation(
                                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                    value: isActive
                                )
                        )
                        .position(
                            x: region.position.x * 200 + 20,
                            y: region.position.y * 360 + 10
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentRegionIndex)
                }
            }
            .frame(height: 380)
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    private var bodyOutline: some View {
        // Simplified body silhouette using shapes
        ZStack {
            // Head
            Circle()
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 44, height: 50)
                .position(x: 120, y: 30)

            // Neck
            Rectangle()
                .fill(AppTheme.textSecondary.opacity(0.2))
                .frame(width: 12, height: 16)
                .position(x: 120, y: 62)

            // Body torso
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 70, height: 130)
                .position(x: 120, y: 145)

            // Left arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 72, y: 145)
                .rotationEffect(.degrees(10), anchor: .top)

            // Right arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 168, y: 145)
                .rotationEffect(.degrees(-10), anchor: .top)

            // Left leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 102, y: 275)

            // Right leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 138, y: 275)

            // Left foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 102, y: 330)

            // Right foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 138, y: 330)
        }
    }

    // MARK: - Guidance Card

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                if let region = viewModel.currentRegion {
                    Circle()
                        .fill(region.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "eye.fill")
                                .font(.system(size: 16))
                                .foregroundColor(region.color)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(region.name)
                            .font(AppFont.title1)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(viewModel.secondsInRegion)/\(viewModel.regionDuration)s")
                            .font(AppFont.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .monospacedDigit()
                    }
                }
                Spacer()

                if viewModel.audioGuidanceEnabled {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.system(size: 18))
                        .opacity(viewModel.isActive ? 1 : 0.3)
                }
            }

            if let region = viewModel.currentRegion {
                Text(region.question)
                    .font(AppFont.body.weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
            }

            // Progress bar for current region
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppTheme.border)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill((viewModel.currentRegion?.color ?? AppTheme.primary))
                        .frame(
                            width: geometry.size.width * Double(viewModel.secondsInRegion) / Double(viewModel.regionDuration),
                            height: 4
                        )
                        .animation(.linear(duration: 1.0), value: viewModel.secondsInRegion)
                }
            }
            .frame(height: 4)

            // Note taking
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("记录感受（可选）")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
                TextField(
                    "例如：这里有些紧绷...",
                    text: Binding(
                        get: { viewModel.sensationNotes[viewModel.currentRegion?.id ?? ""] ?? "" },
                        set: { viewModel.setNote(for: viewModel.currentRegion?.id ?? "", note: $0) }
                    )
                )
                .font(AppFont.body)
                .textFieldStyle(.plain)
                .padding(AppSpacing.sm)
                .background(AppTheme.surface)
                .cornerRadius(AppRadius.sm)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Settings (Idle)

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("扫描设置")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            // Duration picker
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("每个区域停留时间")
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                HStack(spacing: AppSpacing.sm) {
                    ForEach([15, 30, 45, 60], id: \.self) { seconds in
                        Button {
                            viewModel.updateRegionDuration(seconds)
                        } label: {
                            Text("\(seconds)s")
                                .font(AppFont.footnote.weight(.medium))
                                .foregroundColor(viewModel.regionDuration == seconds ? .white : AppTheme.textSecondary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    viewModel.regionDuration == seconds
                                        ? AppTheme.primary : AppTheme.surface
                                )
                                .cornerRadius(AppRadius.sm)
                        }
                    }
                }
            }

            // Audio toggle
            Toggle(isOn: $viewModel.audioGuidanceEnabled) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("音频引导")
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .tint(AppTheme.primary)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Region List

    private var regionListSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("扫描区域")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(Array(CCBodyRegion.all.enumerated()), id: \.element.id) { index, region in
                    regionCell(region: region, index: index)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    private func regionCell(region: CCBodyRegion, index: Int) -> some View {
        let isActive = index == viewModel.currentRegionIndex && viewModel.isActive
        let isCompleted = index < viewModel.currentRegionIndex && viewModel.isActive
        let hasNote = !(viewModel.sensationNotes[region.id] ?? "").isEmpty

        return HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(
                    isActive ? region.color :
                    (isCompleted ? Color(hex: "66BB6A") : AppTheme.border)
                )
                .frame(width: 10, height: 10)

            Text(region.name)
                .font(AppFont.footnote)
                .foregroundColor(
                    isActive ? AppTheme.textPrimary :
                    (isCompleted ? Color(hex: "66BB6A") : AppTheme.textSecondary)
                )
                .lineLimit(1)

            Spacer()

            if hasNote {
                Image(systemName: "note.text")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "8B6F47"))
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: AppSpacing.md) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始扫描")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.primary)
                    .cornerRadius(AppRadius.md)
                }

            case .scanning:
                // Pause/Resume
                Button {
                    viewModel.togglePause()
                } label: {
                    HStack {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        Text(viewModel.isPaused ? "继续" : "暂停")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }

                // Skip
                Button {
                    viewModel.skipToNextRegion()
                } label: {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("跳过")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                }

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重置")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                }

            default:
                EmptyView()
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: AppSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color(hex: "66BB6A").opacity(0.3))
                    .frame(width: 100, height: 100)
                Image(systemName: "eye.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "66BB6A"))
            }
            .padding(.top, AppSpacing.xl)

            Text("身体扫描完成")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)

            Text("你完成了全部\(viewModel.totalRegions)个身体区域的觉察扫描。每一个区域都是你与自己身体重新连接的一步。")
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            // Sensation notes summary
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("身体觉察记录")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                ForEach(CCBodyRegion.all) { region in
                    if let note = viewModel.sensationNotes[region.id], !note.isEmpty {
                        HStack(alignment: .top, spacing: AppSpacing.sm) {
                            Circle()
                                .fill(region.color)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(region.name)
                                    .font(AppFont.footnote.weight(.medium))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text(note)
                                    .font(AppFont.footnote)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            Text(viewModel.completionMessage)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            // Actions
            VStack(spacing: AppSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(AppFont.body.weight(.medium).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, AppSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBodyScanView().environment(CCAppCoordinator())
    }
}
