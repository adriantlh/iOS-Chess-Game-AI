//
//  StatsManager.swift
//  ChessGame
//
//  Tracks and displays aggregate win/loss/draw statistics
//

import Foundation
import Combine

struct PlayerStats: Codable {
    var totalGames: Int = 0
    var wins: Int = 0
    var losses: Int = 0
    var draws: Int = 0
    var easyWins: Int = 0
    var easyLosses: Int = 0
    var mediumWins: Int = 0
    var mediumLosses: Int = 0
    var hardWins: Int = 0
    var hardLosses: Int = 0
    var pvpGames: Int = 0
    var longestGame: Int = 0
    var shortestWin: Int = 0
    var totalMoves: Int = 0

    var winRate: Double {
        guard totalGames > 0 else { return 0 }
        return Double(wins) / Double(totalGames) * 100
    }

    var avgMoves: Double {
        guard totalGames > 0 else { return 0 }
        return Double(totalMoves) / Double(totalGames)
    }
}

class StatsManager: ObservableObject {
    static let shared = StatsManager()
    @Published var stats: PlayerStats

    private let key = "playerStats"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            stats = saved
        } else {
            stats = PlayerStats()
        }
    }

    func recordGame(record: GameRecord) {
        stats.totalGames += 1
        stats.totalMoves += record.moves.count

        if record.moves.count > stats.longestGame {
            stats.longestGame = record.moves.count
        }

        let isWin: Bool
        let isLoss: Bool

        if record.gameMode == .playerVsAI {
            let playerColor = record.playerColor ?? .white
            switch record.result {
            case .whiteWins:
                isWin = playerColor == .white
                isLoss = playerColor == .black
            case .blackWins:
                isWin = playerColor == .black
                isLoss = playerColor == .white
            case .draw, .stalemate:
                isWin = false
                isLoss = false
                stats.draws += 1
            case .inProgress:
                return
            }

            if isWin {
                stats.wins += 1
                if stats.shortestWin == 0 || record.moves.count < stats.shortestWin {
                    stats.shortestWin = record.moves.count
                }
                switch record.aiDifficulty {
                case .easy: stats.easyWins += 1
                case .medium: stats.mediumWins += 1
                case .hard: stats.hardWins += 1
                case .none: break
                }
            } else if isLoss {
                stats.losses += 1
                switch record.aiDifficulty {
                case .easy: stats.easyLosses += 1
                case .medium: stats.mediumLosses += 1
                case .hard: stats.hardLosses += 1
                case .none: break
                }
            }
        } else {
            stats.pvpGames += 1
            // PvP: no win/loss tracking against self
        }

        save()
    }

    func reset() {
        stats = PlayerStats()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
