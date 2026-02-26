//
//  ChessTimer.swift
//  ChessGame
//
//  Chess timer with different time controls
//

import Foundation
import Combine

enum TimeControl: String, Codable, CaseIterable {
    case bullet1 = "Bullet (1+0)"
    case bullet2 = "Bullet (2+1)"
    case blitz3 = "Blitz (3+0)"
    case blitz5 = "Blitz (5+0)"
    case rapid10 = "Rapid (10+0)"
    case rapid15 = "Rapid (15+10)"
    case classical30 = "Classical (30+0)"
    case custom = "Custom"

    var displayName: String {
        return self.rawValue
    }

    var initialTime: TimeInterval {
        switch self {
        case .bullet1: return 60 // 1 minute
        case .bullet2: return 120 // 2 minutes
        case .blitz3: return 180 // 3 minutes
        case .blitz5: return 300 // 5 minutes
        case .rapid10: return 600 // 10 minutes
        case .rapid15: return 900 // 15 minutes
        case .classical30: return 1800 // 30 minutes
        case .custom: return 300 // 5 minutes default
        }
    }

    var increment: TimeInterval {
        switch self {
        case .bullet1: return 0
        case .bullet2: return 1
        case .blitz3: return 0
        case .blitz5: return 0
        case .rapid10: return 0
        case .rapid15: return 10
        case .classical30: return 0
        case .custom: return 0
        }
    }
}

class ChessTimer: ObservableObject {
    @Published var whiteTimeRemaining: TimeInterval
    @Published var blackTimeRemaining: TimeInterval
    @Published var isWhiteTurn: Bool = true
    @Published var isRunning: Bool = false
    @Published var hasTimeExpired: Bool = false
    @Published var losingColor: PieceColor?

    let timeControl: TimeControl
    private var timer: Timer?
    private let updateInterval: TimeInterval = 0.1

    init(timeControl: TimeControl) {
        self.timeControl = timeControl
        self.whiteTimeRemaining = timeControl.initialTime
        self.blackTimeRemaining = timeControl.initialTime
    }

    deinit {
        // Clean up timer when ChessTimer is deallocated
        stopTimer()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTimer()
    }

    func pause() {
        isRunning = false
        stopTimer()
    }

    func switchTurn(to color: PieceColor) {
        // Add increment to the player who just moved
        if isWhiteTurn {
            whiteTimeRemaining += timeControl.increment
        } else {
            blackTimeRemaining += timeControl.increment
        }

        isWhiteTurn = (color == .white)
    }

    func reset() {
        stopTimer()
        isRunning = false
        hasTimeExpired = false
        losingColor = nil
        whiteTimeRemaining = timeControl.initialTime
        blackTimeRemaining = timeControl.initialTime
        isWhiteTurn = true
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard isRunning && !hasTimeExpired else { return }

        if isWhiteTurn {
            whiteTimeRemaining -= updateInterval
            if whiteTimeRemaining <= 0 {
                whiteTimeRemaining = 0
                hasTimeExpired = true
                losingColor = .white
                pause()
            }
        } else {
            blackTimeRemaining -= updateInterval
            if blackTimeRemaining <= 0 {
                blackTimeRemaining = 0
                hasTimeExpired = true
                losingColor = .black
                pause()
            }
        }
    }

    func formattedTime(for color: PieceColor) -> String {
        let time = color == .white ? whiteTimeRemaining : blackTimeRemaining
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let deciseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)

        if time < 60 {
            return String(format: "%d.%d", seconds, deciseconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
