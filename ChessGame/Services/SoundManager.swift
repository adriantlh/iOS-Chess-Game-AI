//
//  SoundManager.swift
//  ChessGame
//
//  Manages chess sound effects using system sounds
//

import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private var soundEnabled: Bool {
        UserDefaults.standard.bool(forKey: "soundEnabled")
    }

    // Generate a short tone programmatically using AVAudioPlayer
    private func playTone(frequency: Double, duration: Double, volume: Float = 0.3) {
        guard soundEnabled else { return }

        let sampleRate: Double = 44100
        let samples = Int(sampleRate * duration)
        var data = Data()

        // WAV header
        let dataSize = samples * 2
        let fileSize = 44 + dataSize
        data.append(contentsOf: "RIFF".utf8)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(fileSize - 8).littleEndian) { Array($0) })
        data.append(contentsOf: "WAVE".utf8)
        data.append(contentsOf: "fmt ".utf8)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // PCM
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // Mono
        data.append(contentsOf: withUnsafeBytes(of: UInt32(44100).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt32(88200).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) })
        data.append(contentsOf: "data".utf8)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })

        // Generate samples with envelope
        for i in 0..<samples {
            let t = Double(i) / sampleRate
            let envelope = min(1.0, min(t / 0.005, (duration - t) / 0.01))
            let sample = sin(2.0 * .pi * frequency * t) * envelope * Double(volume)
            let intSample = Int16(max(-32767, min(32767, sample * 32767)))
            data.append(contentsOf: withUnsafeBytes(of: intSample.littleEndian) { Array($0) })
        }

        audioPlayer = try? AVAudioPlayer(data: data)
        audioPlayer?.play()
    }

    func playMove() {
        playTone(frequency: 440, duration: 0.06, volume: 0.2)
    }

    func playCapture() {
        playTone(frequency: 260, duration: 0.1, volume: 0.3)
    }

    func playCheck() {
        playTone(frequency: 660, duration: 0.12, volume: 0.35)
    }

    func playCastle() {
        playTone(frequency: 350, duration: 0.08, volume: 0.25)
    }

    func playPromotion() {
        playTone(frequency: 523, duration: 0.15, volume: 0.3)
    }

    func playGameOver() {
        playTone(frequency: 330, duration: 0.25, volume: 0.35)
    }

    func playIllegal() {
        playTone(frequency: 200, duration: 0.08, volume: 0.15)
    }
}
