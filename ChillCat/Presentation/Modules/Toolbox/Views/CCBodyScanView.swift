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
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCBodyScanViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    scanContent
                }
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
            .padding(.bottom, theme.spacing3XL)
        }
        .background(
            LinearGradient(
                colors: [theme.softPurpleLight, theme.softPinkLight],
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
                    .foregroundColor(theme.primary)
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
        VStack(spacing: theme.spacingXL) {
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
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                if let region = viewModel.currentRegion, viewModel.isActive {
                    Text("\(region.name) (\(viewModel.currentRegionIndex + 1)/\(viewModel.totalRegions))")
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.textSecondary)
                }
            }

            Spacer()

            // Timer display
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundColor(theme.textMuted)
                    Text(viewModel.isActive ? viewModel.formattedRemaining : viewModel.formattedTotal)
                        .font(theme.fontH2)
                        .foregroundColor(theme.textPrimary)
                        .monospacedDigit()
                }
                if viewModel.isActive {
                    Text("剩余")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                }
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Body Outline

    private var bodyOutlineSection: some View {
        VStack(spacing: theme.spacingSM) {
            Text("身体地图")
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)
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
                            (isCompleted ? theme.softGreen.opacity(0.4) : Color.clear)
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
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    private var bodyOutline: some View {
        // Simplified body silhouette using shapes
        ZStack {
            // Head
            Circle()
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 44, height: 50)
                .position(x: 120, y: 30)

            // Neck
            Rectangle()
                .fill(theme.textMuted.opacity(0.2))
                .frame(width: 12, height: 16)
                .position(x: 120, y: 62)

            // Body torso
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 70, height: 130)
                .position(x: 120, y: 145)

            // Left arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 72, y: 145)
                .rotationEffect(.degrees(10), anchor: .top)

            // Right arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 168, y: 145)
                .rotationEffect(.degrees(-10), anchor: .top)

            // Left leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 102, y: 275)

            // Right leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 138, y: 275)

            // Left foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 102, y: 330)

            // Right foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(theme.textMuted.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 138, y: 330)
        }
    }

    // MARK: - Guidance Card

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
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
                            .font(theme.fontH2)
                            .foregroundColor(theme.textPrimary)
                        Text("\(viewModel.secondsInRegion)/\(viewModel.regionDuration)s")
                            .font(theme.fontCaption)
                            .foregroundColor(theme.textMuted)
                            .monospacedDigit()
                    }
                }
                Spacer()

                if viewModel.audioGuidanceEnabled {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(theme.primary)
                        .font(.system(size: 18))
                        .opacity(viewModel.isActive ? 1 : 0.3)
                }
            }

            if let region = viewModel.currentRegion {
                Text(region.question)
                    .font(theme.fontBodyL)
                    .foregroundColor(theme.textSecondary)
                    .lineSpacing(4)
            }

            // Progress bar for current region
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.divider)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill((viewModel.currentRegion?.color ?? theme.primary))
                        .frame(
                            width: geometry.size.width * Double(viewModel.secondsInRegion) / Double(viewModel.regionDuration),
                            height: 4
                        )
                        .animation(.linear(duration: 1.0), value: viewModel.secondsInRegion)
                }
            }
            .frame(height: 4)

            // Note taking
            VStack(alignment: .leading, spacing: theme.spacingXS) {
                Text("记录感受（可选）")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
                TextField(
                    "例如：这里有些紧绷...",
                    text: Binding(
                        get: { viewModel.sensationNotes[viewModel.currentRegion?.id ?? ""] ?? "" },
                        set: { viewModel.setNote(for: viewModel.currentRegion?.id ?? "", note: $0) }
                    )
                )
                .font(theme.fontBody)
                .textFieldStyle(.plain)
                .padding(theme.spacingSM)
                .background(theme.surface)
                .cornerRadius(theme.radiusSM)
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Settings (Idle)

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            Text("扫描设置")
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)

            // Duration picker
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("每个区域停留时间")
                    .font(theme.fontBody)
                    .foregroundColor(theme.textSecondary)
                HStack(spacing: theme.spacingSM) {
                    ForEach([15, 30, 45, 60], id: \.self) { seconds in
                        Button {
                            viewModel.updateRegionDuration(seconds)
                        } label: {
                            Text("\(seconds)s")
                                .font(theme.fontBodyS.weight(.medium))
                                .foregroundColor(viewModel.regionDuration == seconds ? .white : theme.textSecondary)
                                .padding(.horizontal, theme.spacingMD)
                                .padding(.vertical, theme.spacingSM)
                                .background(
                                    viewModel.regionDuration == seconds
                                        ? theme.primary : theme.surface
                                )
                                .cornerRadius(theme.radiusSM)
                        }
                    }
                }
            }

            // Audio toggle
            Toggle(isOn: $viewModel.audioGuidanceEnabled) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(theme.primary)
                    Text("音频引导")
                        .font(theme.fontBody)
                        .foregroundColor(theme.textPrimary)
                }
            }
            .tint(theme.primary)
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Region List

    private var regionListSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            Text("扫描区域")
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.spacingSM),
                    GridItem(.flexible(), spacing: theme.spacingSM),
                ],
                spacing: theme.spacingSM
            ) {
                ForEach(Array(CCBodyRegion.all.enumerated()), id: \.element.id) { index, region in
                    regionCell(region: region, index: index)
                }
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    private func regionCell(region: CCBodyRegion, index: Int) -> some View {
        let isActive = index == viewModel.currentRegionIndex && viewModel.isActive
        let isCompleted = index < viewModel.currentRegionIndex && viewModel.isActive
        let hasNote = !(viewModel.sensationNotes[region.id] ?? "").isEmpty

        return HStack(spacing: theme.spacingSM) {
            Circle()
                .fill(
                    isActive ? region.color :
                    (isCompleted ? theme.softGreen : theme.divider)
                )
                .frame(width: 10, height: 10)

            Text(region.name)
                .font(theme.fontBodyS)
                .foregroundColor(
                    isActive ? theme.textPrimary :
                    (isCompleted ? theme.softGreen : theme.textMuted)
                )
                .lineLimit(1)

            Spacer()

            if hasNote {
                Image(systemName: "note.text")
                    .font(.system(size: 10))
                    .foregroundColor(theme.warm)
            }
        }
        .padding(.vertical, theme.spacingXS)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: theme.spacingMD) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始扫描")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.primary)
                    .cornerRadius(theme.radiusMD)
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
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.primary.opacity(0.1))
                    .cornerRadius(theme.radiusMD)
                }

                // Skip
                Button {
                    viewModel.skipToNextRegion()
                } label: {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("跳过")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重置")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }

            default:
                EmptyView()
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: theme.spacingXL) {
            ZStack {
                Circle()
                    .fill(theme.softGreenLight)
                    .frame(width: 100, height: 100)
                Image(systemName: "eye.fill")
                    .font(.system(size: 44))
                    .foregroundColor(theme.softGreen)
            }
            .padding(.top, theme.spacing2XL)

            Text("身体扫描完成")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)

            Text("你完成了全部\(viewModel.totalRegions)个身体区域的觉察扫描。每一个区域都是你与自己身体重新连接的一步。")
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingLG)

            // Sensation notes summary
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("身体觉察记录")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                ForEach(CCBodyRegion.all) { region in
                    if let note = viewModel.sensationNotes[region.id], !note.isEmpty {
                        HStack(alignment: .top, spacing: theme.spacingSM) {
                            Circle()
                                .fill(region.color)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(region.name)
                                    .font(theme.fontBodyS.weight(.medium))
                                    .foregroundColor(theme.textPrimary)
                                Text(note)
                                    .font(theme.fontBodyS)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            Text(viewModel.completionMessage)
                .font(theme.fontBody)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)

            // Actions
            VStack(spacing: theme.spacingSM) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingMD)
                        .background(theme.primary)
                        .cornerRadius(theme.radiusMD)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(theme.fontBodyL)
                        .foregroundColor(theme.textSecondary)
                }
            }
            .padding(.top, theme.spacingLG)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBodyScanView()
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}
