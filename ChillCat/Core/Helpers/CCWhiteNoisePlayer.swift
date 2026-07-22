//
//  CCWhiteNoisePlayer.swift
//  ChillCat — 白噪音播放器
//

import AVFoundation
import SwiftUI
import Combine

/// 白噪音类型
enum CCWhiteNoiseType: String, CaseIterable {
    case rain   = "white_noise_rain"
    case ocean  = "white_noise_ocean"
    case forest = "white_noise_forest"
    case piano  = "white_noise_piano"

    var displayName: String {
        switch self {
        case .rain:   return "雨声"
        case .ocean:  return "海浪"
        case .forest: return "森林"
        case .piano:  return "钢琴曲"
        }
    }

    var iconName: String {
        switch self {
        case .rain:   return "emotion_sad"
        case .ocean:  return "healing_sound"
        case .forest: return "healing_meditate"
        case .piano:  return "healing_course"
        }
    }

    var color: Color {
        switch self {
        case .rain:   return Color.xuanMint
        case .ocean:  return Color.xuanApricot
        case .forest: return Color.xuanSuccess
        case .piano:  return Color(hex: "A085C6")
        }
    }
}

/// 白噪音播放器 — 单例，全局管理音频播放状态
@MainActor
@Observable
final class CCWhiteNoisePlayer {
    static let shared = CCWhiteNoisePlayer()

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var isPlaying = false
    var currentType: CCWhiteNoiseType?

    /// 开始播放指定类型的白噪音（循环播放）
    func play(type: CCWhiteNoiseType) {
        // 如果正在播放同类型，停止
        if currentType == type && isPlaying {
            stop()
            return
        }

        stop()

        guard let url = Bundle.main.url(
            forResource: type.rawValue,
            withExtension: "mp3"
        ) else {
            LogW("找不到音频文件: \(type.rawValue).mp3", module: .audio, category: "WhiteNoise")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // 无限循环
            player?.volume = 0.5
            player?.play()

            currentType = type
            isPlaying = true
            LogI("开始播放: \(type.displayName)", module: .audio, category: "WhiteNoise")
        } catch {
            LogE("播放失败: \(error.localizedDescription)", module: .audio, category: "WhiteNoise")
        }
    }

    /// 停止播放
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentType = nil
        LogI("已停止", module: .audio, category: "WhiteNoise")
    }

    /// 设置音量 (0.0 ~ 1.0)
    func setVolume(_ volume: Float) {
        player?.volume = max(0, min(1, volume))
    }
}
