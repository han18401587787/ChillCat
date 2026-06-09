//
//  CCAudioPlayerViewModel.swift
//  ChillCat
//
//  冥想音频播放器 ViewModel — 封装 AVAudioPlayer
//

import Foundation
import AVFoundation
import Combine

@MainActor
@Observable
final class CCAudioPlayerViewModel {
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var isLoading = true
    var errorMessage: String?

    private var player: AVAudioPlayer?
    private var timerCancellable: AnyCancellable?
    private var sessionInterruptionCancellable: AnyCancellable?

    // MARK: - Load

    func load(session: CCMeditationSession) async {
        isLoading = true
        errorMessage = nil

        // 若已生成过则直接复用，否则重新生成 WAV
        let url: URL
        if FileManager.default.fileExists(atPath: session.audioURL.path) {
            url = session.audioURL
        } else if let generated = CCAudioGenerator.generate(
            category: session.category,
            duration: session.duration
        ) {
            url = generated
        } else {
            errorMessage = "无法生成冥想音频"
            isLoading = false
            return
        }

        do {
            try configureAudioSession()
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.numberOfLoops = 0
            duration = player?.duration ?? session.duration
            currentTime = 0
            isPlaying = false
            isLoading = false
            observeInterruptions()
        } catch {
            errorMessage = "音频加载失败: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Controls

    func play() {
        guard let player else { return }
        player.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        guard let player else { return }
        player.pause()
        isPlaying = false
        stopTimer()
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimer()
        deactivateAudioSession()
    }

    func seek(to time: TimeInterval) {
        guard let player else { return }
        player.currentTime = max(0, min(time, player.duration))
        currentTime = player.currentTime
    }

    /// 拖动滑块时调用（不暂停播放）
    func seekWhileDragging(to time: TimeInterval) {
        let wasPlaying = isPlaying
        if wasPlaying { player?.pause() }
        seek(to: time)
        if wasPlaying { player?.play() }
    }

    // MARK: - Private

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
                if !player.isPlaying {
                    self.isPlaying = false
                    self.stopTimer()
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func observeInterruptions() {
        sessionInterruptionCancellable = NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                guard let self,
                      let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
                else { return }

                if type == .began {
                    self.pause()
                } else if type == .ended,
                          let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.play()
                    }
                }
            }
    }
}
