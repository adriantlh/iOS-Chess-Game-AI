//
//  GameState.swift
//  ChessGame
//
//  Manages overall game state, mode, and settings
//

import Foundation
import Combine

enum GameMode: String, Codable, CaseIterable {
    case playerVsPlayer = "Player vs Player"
    case playerVsAI = "Player vs AI"
}

enum AIDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var searchDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

enum GameStatus: Equatable {
    case inProgress
    case checkmate(winner: PieceColor)
    case stalemate
    case draw
}

class GameState: ObservableObject {
    @Published var gameMode: GameMode
    @Published var aiDifficulty: AIDifficulty
    @Published var assistedPlayEnabled: Bool
    @Published var playerColor: PieceColor
    @Published var isAIThinking: Bool

    init() {
        self.gameMode = .playerVsPlayer
        self.aiDifficulty = .medium
        self.assistedPlayEnabled = false
        self.playerColor = .white
        self.isAIThinking = false
    }

    func startNewGame(mode: GameMode, difficulty: AIDifficulty = .medium, playerColor: PieceColor = .white) {
        self.gameMode = mode
        self.aiDifficulty = difficulty
        self.playerColor = playerColor
        self.isAIThinking = false
    }
}
