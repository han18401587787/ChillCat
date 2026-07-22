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
            VStack(spacing: XuanSpacing.xl) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    scanContent
                }
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.sm)
            .padding(.bottom, XuanSpacing.xl)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "A085C6").opacity(0.3), Color.xuanPink.opacity(0.3)],
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
                    .foregroundColor(Color.xuanApricot)
                    .accessibilityIdentifier("body_scan_close")
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
        VStack(spacing: XuanSpacing.xl) {
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
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                if let region = viewModel.currentRegion, viewModel.isActive {
                    Text("\(region.name) (\(viewModel.currentRegionIndex + 1)/\(viewModel.totalRegions))")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }

            Spacer()

            // Timer display
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image("other_assess")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanTextSecondary)
                    Text(viewModel.isActive ? viewModel.formattedRemaining : viewModel.formattedTotal)
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)
                        .monospacedDigit()
                }
                if viewModel.isActive {
                    Text("剩余")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Body Outline

    private var bodyOutlineSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            Text("身体地图")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
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
                            (isCompleted ? Color.xuanMint.opacity(0.4) : Color.clear)
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
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    private var bodyOutline: some View {
        // Simplified body silhouette using shapes
        ZStack {
            // Head
            Circle()
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 44, height: 50)
                .position(x: 120, y: 30)

            // Neck
            Rectangle()
                .fill(Color.xuanTextSecondary.opacity(0.2))
                .frame(width: 12, height: 16)
                .position(x: 120, y: 62)

            // Body torso
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 70, height: 130)
                .position(x: 120, y: 145)

            // Left arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 72, y: 145)
                .rotationEffect(.degrees(10), anchor: .top)

            // Right arm
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 12, height: 80)
                .position(x: 168, y: 145)
                .rotationEffect(.degrees(-10), anchor: .top)

            // Left leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 102, y: 275)

            // Right leg
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 100)
                .position(x: 138, y: 275)

            // Left foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 102, y: 330)

            // Right foot
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.xuanTextSecondary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 20, height: 14)
                .position(x: 138, y: 330)
        }
    }

    // MARK: - Guidance Card

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                if let region = viewModel.currentRegion {
                    Circle()
                        .fill(region.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image("healing_scan")
                                .font(.system(size: 16))
                                .foregroundColor(region.color)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(region.name)
                            .font(XuanFont.h1)
                            .foregroundColor(Color.xuanTextPrimary)
                        Text("\(viewModel.secondsInRegion)/\(viewModel.regionDuration)s")
                            .font(XuanFont.bodyM)
                            .foregroundColor(Color.xuanTextSecondary)
                            .monospacedDigit()
                    }
                }
                Spacer()

                if viewModel.audioGuidanceEnabled {
                    Image("healing_sound")
                        .foregroundColor(Color.xuanApricot)
                        .font(.system(size: 18))
                        .opacity(viewModel.isActive ? 1 : 0.3)
                }
            }

            if let region = viewModel.currentRegion {
                Text(region.question)
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineSpacing(4)
            }

            // Progress bar for current region
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.xuanBorder)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill((viewModel.currentRegion?.color ?? Color.xuanApricot))
                        .frame(
                            width: geometry.size.width * Double(viewModel.secondsInRegion) / Double(viewModel.regionDuration),
                            height: 4
                        )
                        .animation(.linear(duration: 1.0), value: viewModel.secondsInRegion)
                }
            }
            .frame(height: 4)

            // Note taking
            VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                Text("记录感受（可选）")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                TextField(
                    "例如：这里有些紧绷...",
                    text: Binding(
                        get: { viewModel.sensationNotes[viewModel.currentRegion?.id ?? ""] ?? "" },
                        set: { viewModel.setNote(for: viewModel.currentRegion?.id ?? "", note: $0) }
                    )
                )
                .font(XuanFont.bodyL)
                .textFieldStyle(.plain)
                .padding(XuanSpacing.sm)
                .background(Color.xuanSurface)
                .cornerRadius(XuanRadius.sm)
                .accessibilityIdentifier("body_scan_note")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Settings (Idle)

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("扫描设置")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            // Duration picker
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("每个区域停留时间")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                HStack(spacing: XuanSpacing.sm) {
                    ForEach([15, 30, 45, 60], id: \.self) { seconds in
                        Button {
                            viewModel.updateRegionDuration(seconds)
                        } label: {
                            Text("\(seconds)s")
                                .font(XuanFont.bodyS.weight(.medium))
                                .foregroundColor(viewModel.regionDuration == seconds ? .white : Color.xuanTextSecondary)
                                .padding(.horizontal, XuanSpacing.md)
                                .padding(.vertical, XuanSpacing.sm)
                                .background(
                                    viewModel.regionDuration == seconds
                                        ? Color.xuanApricot : Color.xuanSurface
                                )
                                .cornerRadius(XuanRadius.sm)
                        }
                        .accessibilityIdentifier("body_scan_duration_\(seconds)")
                    }
                }
            }

            // Audio toggle
            Toggle(isOn: $viewModel.audioGuidanceEnabled) {
                HStack {
                    Image("healing_sound")
                        .foregroundColor(Color.xuanApricot)
                    Text("音频引导")
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextPrimary)
                }
            }
            .tint(Color.xuanApricot)
            .accessibilityIdentifier("body_scan_audio_toggle")
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Region List

    private var regionListSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            Text("扫描区域")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                ],
                spacing: XuanSpacing.sm
            ) {
                ForEach(Array(CCBodyRegion.all.enumerated()), id: \.element.id) { index, region in
                    regionCell(region: region, index: index)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    private func regionCell(region: CCBodyRegion, index: Int) -> some View {
        let isActive = index == viewModel.currentRegionIndex && viewModel.isActive
        let isCompleted = index < viewModel.currentRegionIndex && viewModel.isActive
        let hasNote = !(viewModel.sensationNotes[region.id] ?? "").isEmpty

        return HStack(spacing: XuanSpacing.sm) {
            Circle()
                .fill(
                    isActive ? region.color :
                    (isCompleted ? Color.xuanMint : Color.xuanBorder)
                )
                .frame(width: 10, height: 10)

            Text(region.name)
                .font(XuanFont.bodyS)
                .foregroundColor(
                    isActive ? Color.xuanTextPrimary :
                    (isCompleted ? Color.xuanMint : Color.xuanTextSecondary)
                )
                .lineLimit(1)

            Spacer()

            if hasNote {
                Image("other_diary")
                    .font(.system(size: 10))
                    .foregroundColor(Color.xuanApricotDark)
            }
        }
        .padding(.vertical, XuanSpacing.xs)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: XuanSpacing.md) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image("healing_course")
                        Text("开始扫描")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot)
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("body_scan_start")

            case .scanning:
                // Pause/Resume
                Button {
                    viewModel.togglePause()
                } label: {
                    HStack {
                        CCIconMapper.image(for: viewModel.isPaused ? "play.fill" : "pause.fill")
                        Text(viewModel.isPaused ? "继续" : "暂停")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanApricot)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot.opacity(0.1))
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("body_scan_pause_resume")

                // Skip
                Button {
                    viewModel.skipToNextRegion()
                } label: {
                    HStack {
                        Image("common_refresh")
                        Text("跳过")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("body_scan_skip")

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image("common_refresh")
                        Text("重置")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("body_scan_reset")

            default:
                EmptyView()
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: XuanSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.xuanMint.opacity(0.3))
                    .frame(width: 100, height: 100)
                Image("healing_scan")
                    .font(.system(size: 44))
                    .foregroundColor(Color.xuanMint)
            }
            .padding(.top, XuanSpacing.xl)

            Text("身体扫描完成")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("你完成了全部\(viewModel.totalRegions)个身体区域的觉察扫描。每一个区域都是你与自己身体重新连接的一步。")
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.lg)

            // Sensation notes summary
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("身体觉察记录")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                ForEach(CCBodyRegion.all) { region in
                    if let note = viewModel.sensationNotes[region.id], !note.isEmpty {
                        HStack(alignment: .top, spacing: XuanSpacing.sm) {
                            Circle()
                                .fill(region.color)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(region.name)
                                    .font(XuanFont.bodyS.weight(.medium))
                                    .foregroundColor(Color.xuanTextPrimary)
                                Text(note)
                                    .font(XuanFont.bodyS)
                                    .foregroundColor(Color.xuanTextSecondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            Text(viewModel.completionMessage)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)

            // Actions
            VStack(spacing: XuanSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("body_scan_retry")

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .accessibilityIdentifier("body_scan_back")
            }
            .padding(.top, XuanSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBodyScanView().environment(CCAppCoordinator())
    }
}
