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
    @Published var lastMoveFrom: Position?
    @Published var lastMoveTo: Position?
    @Published var showPromotionDialog = false
    @Published var pendingPromotionFrom: Position?
    @Published var pendingPromotionTo: Position?

    private var ai: ChessAI?
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.board = ChessBoard()
        self.gameState = GameState()

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

    // MARK: - Computed Properties

    var capturedByWhite: [ChessPiece] {
        board.moveHistory
            .compactMap { $0.capturedPiece }
            .filter { $0.color == .black }
            .sorted { $0.type.value > $1.type.value }
    }

    var capturedByBlack: [ChessPiece] {
        board.moveHistory
            .compactMap { $0.capturedPiece }
            .filter { $0.color == .white }
            .sorted { $0.type.value > $1.type.value }
    }

    var materialAdvantage: Int {
        let whiteCaptures = capturedByWhite.reduce(0) { $0 + $1.type.value }
        let blackCaptures = capturedByBlack.reduce(0) { $0 + $1.type.value }
        return whiteCaptures - blackCaptures
    }

    // MARK: - Game Control

    func startNewGame() {
        board = ChessBoard()
        selectedPosition = nil
        possibleMoves = []
        gameStatus = .inProgress
        showGameOverAlert = false
        gameOverMessage = ""
        lastMoveFrom = nil
        lastMoveTo = nil

        if gameState.gameMode == .playerVsAI {
            ai = ChessAI(difficulty: gameState.aiDifficulty)

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

        if gameState.isAIThinking { return }

        if case .inProgress = gameStatus {
        } else {
            return
        }

        if gameState.gameMode == .playerVsAI && board.currentTurn != gameState.playerColor {
            return
        }

        if let selected = selectedPosition {
            if possibleMoves.contains(position) {
                makeMove(from: selected, to: position)
            } else if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                selectPiece(at: position)
            } else {
                deselectPiece()
            }
        } else {
            if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                selectPiece(at: position)
            }
        }
    }

    private func selectPiece(at position: Position) {
        selectedPosition = position
        possibleMoves = board.getPossibleMoves(from: position)
        triggerHaptic(.light)
    }

    private func deselectPiece() {
        selectedPosition = nil
        possibleMoves = []
    }

    private func makeMove(from: Position, to: Position) {
        // Check if this is a promotion move - show dialog for player choice
        if board.isPromotionMove(from: from, to: to) {
            pendingPromotionFrom = from
            pendingPromotionTo = to
            showPromotionDialog = true
            return
        }

        executeMove(from: from, to: to)
    }

    func completePromotion(pieceType: PieceType) {
        guard let from = pendingPromotionFrom, let to = pendingPromotionTo else { return }
        showPromotionDialog = false
        pendingPromotionFrom = nil
        pendingPromotionTo = nil
        executeMove(from: from, to: to, promotionType: pieceType)
    }

    private func executeMove(from: Position, to: Position, promotionType: PieceType = .queen) {
        if let move = board.makeMove(from: from, to: to, promotionType: promotionType) {
            lastMoveFrom = from
            lastMoveTo = to
            deselectPiece()
            updateThreatenedPieces()

            if move.capturedPiece != nil {
                triggerHaptic(.medium)
            } else {
                triggerHaptic(.light)
            }

            checkGameStatus()

            if gameState.gameMode == .playerVsAI && gameStatus == .inProgress {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if let executedMove = self.board.makeMove(from: move.from, to: move.to) {
                            self.lastMoveFrom = move.from
                            self.lastMoveTo = move.to
                            self.updateThreatenedPieces()

                            if executedMove.capturedPiece != nil {
                                self.triggerHaptic(.medium)
                            } else {
                                self.triggerHaptic(.light)
                            }

                            self.checkGameStatus()
                        }
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
        if gameState.gameMode == .playerVsAI {
            _ = board.undoLastMove()
            _ = board.undoLastMove()
        } else {
            _ = board.undoLastMove()
        }

        // Update last move highlight
        if let lastMove = board.moveHistory.last {
            lastMoveFrom = lastMove.from
            lastMoveTo = lastMove.to
        } else {
            lastMoveFrom = nil
            lastMoveTo = nil
        }

        deselectPiece()
        updateThreatenedPieces()

        if gameStatus != .inProgress {
            gameStatus = .inProgress
            showGameOverAlert = false
            gameOverMessage = ""
        }
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
            triggerNotification(.success)
        } else if board.isStalemate(color: currentColor) {
            gameStatus = .stalemate
            gameOverMessage = "Game ended in stalemate!"
            showGameOverAlert = true
        } else if board.isInsufficientMaterial() {
            gameStatus = .draw
            gameOverMessage = "Draw by insufficient material!"
            showGameOverAlert = true
        } else if board.isDrawByFiftyMoveRule() {
            gameStatus = .draw
            gameOverMessage = "Draw by fifty-move rule!"
            showGameOverAlert = true
        } else if board.isInCheck(color: currentColor) {
            triggerNotification(.warning)
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

    // MARK: - Haptic Feedback

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
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

    func isLastMoveSquare(_ position: Position) -> Bool {
        return position == lastMoveFrom || position == lastMoveTo
    }
}
