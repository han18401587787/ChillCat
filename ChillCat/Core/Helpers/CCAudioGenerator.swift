//
//  CCAudioGenerator.swift
//  ChillCat
//
//  生成冥想音频（正弦波 WAV），供 AVAudioPlayer 播放。
//  每个类别使用不同频率的 Solfeggio 音调 + 低频调制营造氛围感。
//

import Foundation
import AVFoundation

enum CCAudioGenerator {
    /// 生成一段冥想 WAV 音频，返回文件 URL
    static func generate(
        category: CCMeditationCategory,
        duration: TimeInterval
    ) -> URL? {
        let sampleRate: Double = 44100
        let totalSamples = Int(duration * sampleRate)
        let channels = 1
        let bitsPerSample = 16
        let bytesPerSample = bitsPerSample / 8
        let dataSize = totalSamples * channels * bytesPerSample
        let headerSize = 44  // standard PCM WAV header

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("chillcat_\(category.rawValue).wav")

        guard let fileHandle = try? FileHandle(forWritingTo: url) else {
            // 文件尚不存在，创建它
            FileManager.default.createFile(atPath: url.path, contents: nil)
            guard let handle = try? FileHandle(forWritingTo: url) else { return nil }
            defer { try? handle.close() }
            writeWAV(handle: handle, sampleRate: sampleRate, channels: channels,
                     bitsPerSample: bitsPerSample, dataSize: dataSize,
                     category: category, duration: duration)
            return url
        }
        defer { try? fileHandle.close() }
        writeWAV(handle: fileHandle, sampleRate: sampleRate, channels: channels,
                 bitsPerSample: bitsPerSample, dataSize: dataSize,
                 category: category, duration: duration)
        return url
    }

    private static func writeWAV(
        handle: FileHandle,
        sampleRate: Double,
        channels: Int,
        bitsPerSample: Int,
        dataSize: Int,
        category: CCMeditationCategory,
        duration: TimeInterval
    ) {
        let sampleRateInt = UInt32(sampleRate)
        let byteRate = UInt32(Int(sampleRate) * channels * bitsPerSample / 8)
        let blockAlign = UInt16(channels * bitsPerSample / 8)
        var fileSize: UInt32 = UInt32(36 + dataSize)

        // RIFF header
        handle.write("RIFF".data(using: .ascii)!)
        handle.write(Data(bytes: &fileSize, count: 4).reversedIfNeeded)
        handle.write("WAVE".data(using: .ascii)!)

        // fmt subchunk
        handle.write("fmt ".data(using: .ascii)!)
        var fmtSize: UInt32 = 16
        handle.write(withUnsafeBytes(of: &fmtSize) { Data($0) }.reversedIfNeeded)
        var audioFormat: UInt16 = 1  // PCM
        handle.write(withUnsafeBytes(of: &audioFormat) { Data($0) }.reversedIfNeeded)
        var ch: UInt16 = UInt16(channels)
        handle.write(withUnsafeBytes(of: &ch) { Data($0) }.reversedIfNeeded)
        var sr = sampleRateInt
        handle.write(withUnsafeBytes(of: &sr) { Data($0) }.reversedIfNeeded)
        var br = byteRate
        handle.write(withUnsafeBytes(of: &br) { Data($0) }.reversedIfNeeded)
        var ba = blockAlign
        handle.write(withUnsafeBytes(of: &ba) { Data($0) }.reversedIfNeeded)
        var bps: UInt16 = UInt16(bitsPerSample)
        handle.write(withUnsafeBytes(of: &bps) { Data($0) }.reversedIfNeeded)

        // data subchunk
        handle.write("data".data(using: .ascii)!)
        var ds: UInt32 = UInt32(dataSize)
        handle.write(withUnsafeBytes(of: &ds) { Data($0) }.reversedIfNeeded)

        // PCM samples
        let totalSamples = Int(duration * Double(sampleRateInt))
        let baseFreq = category.toneFrequency
        let modFreq: Double = {
            switch category {
            case .sleep: return 3.0
            case .relax: return 8.0
            case .anxiety: return 6.0
            }
        }()

        var samples = Data(capacity: dataSize)
        let twoPiSR = 2.0 * .pi / Double(sampleRateInt)
        let fadeInSamples = Int(0.5 * Double(sampleRateInt))
        let fadeOutSamples = Int(1.5 * Double(sampleRateInt))

        for i in 0..<totalSamples {
            let t = Double(i)
            let envelope: Double
            if i < fadeInSamples {
                envelope = Double(i) / Double(fadeInSamples)
            } else if i > totalSamples - fadeOutSamples {
                envelope = Double(totalSamples - i) / Double(fadeOutSamples)
            } else {
                envelope = 1.0
            }

            let mod = sin(twoPiSR * modFreq * t) * 0.15
            let freq = baseFreq * (1.0 + mod)
            let value = sin(twoPiSR * freq * t) * 0.3 * envelope
            let sample = Int16(clamping: Int(value * Double(Int16.max)))
            var s = sample
            samples.append(withUnsafeBytes(of: &s) { Data($0) }.reversedIfNeeded)
        }

        handle.write(samples)
    }
}

private extension Data {
    var reversedIfNeeded: Data {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            return self
        }
        return Data(self.reversed())
    }
}
