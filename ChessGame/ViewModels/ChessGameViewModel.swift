//
//  ChessGameViewModel.swift
//  ChessGame
//
//  View model managing the chess game state and user interactions
//

import Foundation
import SwiftUI
import Combine

class ChessGameViewModel: ObservableObject {
    @Published var board: ChessBoard
    @Published var gameState: GameState
    @Published var selectedPosition: Position?
    @Published var possibleMoves: [Position] = []
    @Published var threatenedPieces: Set<Position> = []
    @Published var gameStatus: GameStatus = .inProgress
    @Published var showGameOverAlert = false
    @Published var gameOverMessage = ""

    private var ai: ChessAI?
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.board = ChessBoard()
        self.gameState = GameState()

        // Update threatened pieces when assisted play is enabled
        gameState.$assistedPlayEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.updateThreatenedPieces()
                } else {
                    self?.threatenedPieces = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Game Control

    func startNewGame() {
        board = ChessBoard()
        selectedPosition = nil
        possibleMoves = []
        gameStatus = .inProgress
        showGameOverAlert = false
        gameOverMessage = ""

        if gameState.gameMode == .playerVsAI {
            ai = ChessAI(difficulty: gameState.aiDifficulty)

            // If AI plays white, make first move
            if gameState.playerColor == .black {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            }
        } else {
            ai = nil
        }

        updateThreatenedPieces()
    }

    func restartGame() {
        startNewGame()
    }

    // MARK: - Move Handling

    func handleSquareTap(row: Int, col: Int) {
        let position = Position(row: row, col: col)

        // If AI is thinking, ignore input
        if gameState.isAIThinking {
            return
        }

        // If game is over, ignore input
        if case .inProgress = gameStatus {
            // Continue
        } else {
            return
        }

        // If playing against AI and it's AI's turn, ignore input
        if gameState.gameMode == .playerVsAI && board.currentTurn != gameState.playerColor {
            return
        }

        if let selected = selectedPosition {
            // Try to make a move
            if possibleMoves.contains(position) {
                makeMove(from: selected, to: position)
            } else if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                // Select a different piece
                selectPiece(at: position)
            } else {
                // Deselect
                deselectPiece()
            }
        } else {
            // Select a piece
            if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                selectPiece(at: position)
            }
        }
    }

    private func selectPiece(at position: Position) {
        selectedPosition = position
        possibleMoves = board.getPossibleMoves(from: position)
    }

    private func deselectPiece() {
        selectedPosition = nil
        possibleMoves = []
    }

    private func makeMove(from: Position, to: Position) {
        if let _ = board.makeMove(from: from, to: to) {
            deselectPiece()
            updateThreatenedPieces()
            checkGameStatus()

            // If playing against AI, make AI move
            if gameState.gameMode == .playerVsAI && gameStatus == .inProgress {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            }
        }
    }

    private func makeAIMove() {
        guard let ai = ai else { return }

        gameState.isAIThinking = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            if let move = ai.getBestMove(board: self.board) {
                DispatchQueue.main.async {
                    if let _ = self.board.makeMove(from: move.from, to: move.to) {
                        self.updateThreatenedPieces()
                        self.checkGameStatus()
                    }
                    self.gameState.isAIThinking = false
                }
            } else {
                DispatchQueue.main.async {
                    self.gameState.isAIThinking = false
                }
            }
        }
    }

    // MARK: - Undo

    func undoMove() {
        // In PvP mode, undo one move
        // In PvAI mode, undo two moves (player's move and AI's move)
        if gameState.gameMode == .playerVsAI {
            _ = board.undoLastMove()
            _ = board.undoLastMove()
        } else {
            _ = board.undoLastMove()
        }

        deselectPiece()
        updateThreatenedPieces()
        checkGameStatus()
    }

    func canUndo() -> Bool {
        if gameState.gameMode == .playerVsAI {
            return board.moveHistory.count >= 2
        } else {
            return !board.moveHistory.isEmpty
        }
    }

    // MARK: - Game Status

    private func checkGameStatus() {
        let currentColor = board.currentTurn

        if board.isCheckmate(color: currentColor) {
            gameStatus = .checkmate(winner: currentColor.opposite)
            gameOverMessage = "\(currentColor.opposite.rawValue.capitalized) wins by checkmate!"
            showGameOverAlert = true
        } else if board.isStalemate(color: currentColor) {
            gameStatus = .stalemate
            gameOverMessage = "Game ended in stalemate!"
            showGameOverAlert = true
        }
    }

    // MARK: - Assisted Play

    private func updateThreatenedPieces() {
        if gameState.assistedPlayEnabled {
            threatenedPieces = board.getThreatenedPieces(color: board.currentTurn)
        } else {
            threatenedPieces = []
        }
    }

    func toggleAssistedPlay() {
        gameState.assistedPlayEnabled.toggle()
    }

    // MARK: - Helpers

    func isSquareSelected(_ position: Position) -> Bool {
        return selectedPosition == position
    }

    func isSquarePossibleMove(_ position: Position) -> Bool {
        return possibleMoves.contains(position)
    }

    func isSquareThreatened(_ position: Position) -> Bool {
        return threatenedPieces.contains(position)
    }

    func isSquareInCheck(_ position: Position) -> Bool {
        guard let piece = board.pieceAt(position),
              piece.type == .king,
              piece.color == board.currentTurn else {
            return false
        }
        return board.isInCheck(color: piece.color)
    }
}
