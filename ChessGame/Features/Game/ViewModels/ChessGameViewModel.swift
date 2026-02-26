//
//  ChessGameViewModel.swift
//  ChessGame
//
//  View model managing the chess game state and user interactions
//

import Foundation
import SwiftUI
import UIKit
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

    // Relay for nested ObservableObject — ensures SwiftUI updates when AI thinking changes
    @Published var isAIThinking = false

    // Move navigation
    @Published var viewingMoveIndex: Int?  // nil = live position
    @Published var viewingBoard: ChessBoard?

    // Opening name
    @Published var openingName: String?

    // Hint system
    @Published var hintFrom: Position?
    @Published var hintTo: Position?
    @Published var hintDescription: String?
    @Published var isCalculatingHint = false

    // Drag-and-drop
    @Published var dragFromPosition: Position?
    @Published var dragOffset: CGSize = .zero
    @Published var isDragging = false

    // Draw offer
    @Published var showDrawOffer = false
    @Published var showConfirmResign = false

    // Timer (owned by ViewModel so @Published changes propagate to SwiftUI)
    @Published var timer: ChessTimer?
    private var timerCancellable: AnyCancellable?

    private var ai: ChessAI?
    private var hintEngine = HintEngine()
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

        // Relay isAIThinking from nested GameState to this ViewModel's @Published
        gameState.$isAIThinking
            .sink { [weak self] thinking in
                self?.isAIThinking = thinking
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

    var isViewingHistory: Bool {
        viewingMoveIndex != nil
    }

    /// The board to display — either the historical position or the live board
    var displayBoard: ChessBoard {
        viewingBoard ?? board
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
        viewingMoveIndex = nil
        viewingBoard = nil
        openingName = nil
        clearHint()

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

    // MARK: - Timer Management

    func setupTimer(timeControl: TimeControl) {
        let newTimer = ChessTimer(timeControl: timeControl)

        // Forward timer's objectWillChange to ViewModel for SwiftUI observation
        timerCancellable = newTimer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }

        // Handle time expiration
        newTimer.$hasTimeExpired
            .removeDuplicates()
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleTimeExpiration()
            }
            .store(in: &cancellables)

        timer = newTimer
        newTimer.start()
    }

    private func handleTimeExpiration() {
        guard let losingColor = timer?.losingColor else { return }
        timer?.pause()
        gameStatus = .timeExpired(loser: losingColor)
        gameOverMessage = "\(losingColor.opposite.rawValue.capitalized) wins on time!"
        showGameOverAlert = true
        SoundManager.shared.playGameOver()
    }

    // MARK: - Sound & Haptics (shared helper)

    private func playMoveSound(for move: ChessMove) {
        if move.isCastling {
            SoundManager.shared.playCastle()
        } else if move.capturedPiece != nil {
            SoundManager.shared.playCapture()
        } else if move.isPromotion {
            SoundManager.shared.playPromotion()
        } else {
            SoundManager.shared.playMove()
        }

        if move.capturedPiece != nil {
            triggerHaptic(.medium)
        } else {
            triggerHaptic(.light)
        }
    }

    // MARK: - Move Handling

    func handleSquareTap(row: Int, col: Int) {
        // Return to live position if viewing history
        if isViewingHistory {
            goToLivePosition()
            return
        }

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
        if board.isPromotionMove(from: from, to: to) {
            if UserDefaults.standard.bool(forKey: "autoPromotionQueen") {
                executeMove(from: from, to: to, promotionType: .queen)
                return
            }
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
            clearHint()
            updateThreatenedPieces()

            playMoveSound(for: move)

            // Update opening name
            openingName = OpeningBook.identify(moves: board.moveHistory)

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

        // Copy board before dispatching to background thread for thread safety
        let boardCopy = board.copyBoard()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let move = ai.getBestMove(board: boardCopy)

            DispatchQueue.main.async {
                guard let self = self else { return }

                if let move = move {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if let executedMove = self.board.makeMove(from: move.from, to: move.to) {
                            self.lastMoveFrom = move.from
                            self.lastMoveTo = move.to
                            self.updateThreatenedPieces()

                            self.playMoveSound(for: executedMove)

                            self.openingName = OpeningBook.identify(moves: self.board.moveHistory)
                            self.checkGameStatus()
                        }
                    }
                }
                self.gameState.isAIThinking = false
            }
        }
    }

    // MARK: - Drag and Drop

    func handleDragStart(row: Int, col: Int) {
        if isViewingHistory { return }
        if gameState.isAIThinking { return }
        guard gameStatus == .inProgress else { return }

        if gameState.gameMode == .playerVsAI && board.currentTurn != gameState.playerColor {
            return
        }

        let position = Position(row: row, col: col)
        guard let piece = board.pieceAt(position), piece.color == board.currentTurn else { return }

        dragFromPosition = position
        selectedPosition = position
        possibleMoves = board.getPossibleMoves(from: position)
        isDragging = true
        triggerHaptic(.light)
    }

    func handleDragEnd(toRow: Int, toCol: Int) {
        guard isDragging, let from = dragFromPosition else {
            cancelDrag()
            return
        }

        let to = Position(row: toRow, col: toCol)

        if possibleMoves.contains(to) {
            makeMove(from: from, to: to)
        } else {
            SoundManager.shared.playIllegal()
        }

        cancelDrag()
    }

    func cancelDrag() {
        dragFromPosition = nil
        dragOffset = .zero
        isDragging = false
    }

    // MARK: - Move Navigation

    func goToMove(index: Int) {
        guard index >= 0, index < board.moveHistory.count else { return }

        let tempBoard = ChessBoard()
        for i in 0...index {
            let move = board.moveHistory[i]
            _ = tempBoard.makeMove(from: move.from, to: move.to,
                                   promotionType: move.promotionPiece ?? .queen)
        }

        viewingMoveIndex = index
        viewingBoard = tempBoard
    }

    func goToLivePosition() {
        viewingMoveIndex = nil
        viewingBoard = nil
    }

    func goForward() {
        if let current = viewingMoveIndex {
            if current < board.moveHistory.count - 1 {
                goToMove(index: current + 1)
            } else {
                goToLivePosition()
            }
        }
    }

    func goBack() {
        if let current = viewingMoveIndex {
            if current > 0 {
                goToMove(index: current - 1)
            }
        } else if !board.moveHistory.isEmpty {
            goToMove(index: board.moveHistory.count - 1)
        }
    }

    func goToStart() {
        if !board.moveHistory.isEmpty {
            goToMove(index: 0)
        }
    }

    // MARK: - Hints

    func requestHint() {
        guard gameStatus == .inProgress else { return }
        guard !gameState.isAIThinking else { return }

        isCalculatingHint = true

        // Copy board before dispatching to background thread for thread safety
        let boardCopy = board.copyBoard()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let hint = self.hintEngine.getBestMoveHint(board: boardCopy)

            DispatchQueue.main.async {
                self.isCalculatingHint = false
                if let hint = hint {
                    self.hintFrom = hint.from
                    self.hintTo = hint.to
                    self.hintDescription = hint.description
                    self.selectedPosition = hint.from
                    self.possibleMoves = [hint.to]
                }
            }
        }
    }

    func clearHint() {
        hintFrom = nil
        hintTo = nil
        hintDescription = nil
    }

    // MARK: - Resign / Draw

    func resign() {
        let loser = board.currentTurn
        gameStatus = .resigned(loser: loser)
        gameOverMessage = "\(loser.opposite.rawValue.capitalized) wins by resignation!"
        showGameOverAlert = true
        SoundManager.shared.playGameOver()
        triggerNotification(.success)
    }

    func offerDraw() {
        if gameState.gameMode == .playerVsAI {
            // AI accepts draws only if position is roughly equal
            let eval = board.evaluateBoard()
            let threshold = 200
            if abs(eval) < threshold {
                acceptDraw()
            } else {
                // AI declines
                showDrawOffer = false
            }
        } else {
            showDrawOffer = true
        }
    }

    func acceptDraw() {
        gameStatus = .drawByAgreement
        gameOverMessage = "Game drawn by agreement!"
        showGameOverAlert = true
        showDrawOffer = false
        SoundManager.shared.playGameOver()
    }

    func declineDraw() {
        showDrawOffer = false
    }

    // MARK: - Undo

    func undoMove() {
        if gameState.gameMode == .playerVsAI {
            _ = board.undoLastMove()
            _ = board.undoLastMove()
        } else {
            _ = board.undoLastMove()
        }

        if let lastMove = board.moveHistory.last {
            lastMoveFrom = lastMove.from
            lastMoveTo = lastMove.to
        } else {
            lastMoveFrom = nil
            lastMoveTo = nil
        }

        deselectPiece()
        clearHint()
        updateThreatenedPieces()
        openingName = OpeningBook.identify(moves: board.moveHistory)

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

    // MARK: - PGN Export

    func exportPGN() -> String {
        let result: GameResult
        switch gameStatus {
        case .checkmate(let winner):
            result = winner == .white ? .whiteWins : .blackWins
        case .stalemate:
            result = .stalemate
        case .draw, .drawByAgreement:
            result = .draw
        case .resigned(let loser):
            result = loser == .white ? .blackWins : .whiteWins
        case .timeExpired(let loser):
            result = loser == .white ? .blackWins : .whiteWins
        case .inProgress:
            result = .inProgress
        }

        let white: String
        let black: String
        if gameState.gameMode == .playerVsAI {
            white = gameState.playerColor == .white ? "Player" : "AI (\(gameState.aiDifficulty.rawValue))"
            black = gameState.playerColor == .black ? "Player" : "AI (\(gameState.aiDifficulty.rawValue))"
        } else {
            white = "Player 1"
            black = "Player 2"
        }

        return PGNExporter.export(
            moves: board.moveHistory,
            result: result,
            white: white,
            black: black
        )
    }

    // MARK: - Game Status

    private func checkGameStatus() {
        let currentColor = board.currentTurn

        if board.isCheckmate(color: currentColor) {
            gameStatus = .checkmate(winner: currentColor.opposite)
            gameOverMessage = "\(currentColor.opposite.rawValue.capitalized) wins by checkmate!"
            showGameOverAlert = true
            SoundManager.shared.playGameOver()
            triggerNotification(.success)
        } else if board.isStalemate(color: currentColor) {
            gameStatus = .stalemate
            gameOverMessage = "Game ended in stalemate!"
            showGameOverAlert = true
            SoundManager.shared.playGameOver()
        } else if board.isInsufficientMaterial() {
            gameStatus = .draw
            gameOverMessage = "Draw by insufficient material!"
            showGameOverAlert = true
            SoundManager.shared.playGameOver()
        } else if board.isDrawByFiftyMoveRule() {
            gameStatus = .draw
            gameOverMessage = "Draw by fifty-move rule!"
            showGameOverAlert = true
            SoundManager.shared.playGameOver()
        } else if board.isInCheck(color: currentColor) {
            SoundManager.shared.playCheck()
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
        guard UserDefaults.standard.bool(forKey: "vibrationEnabled") else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserDefaults.standard.bool(forKey: "vibrationEnabled") else { return }
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
        let checkBoard = displayBoard
        guard let piece = checkBoard.pieceAt(position),
              piece.type == .king,
              piece.color == checkBoard.currentTurn else {
            return false
        }
        return checkBoard.isInCheck(color: piece.color)
    }

    func isLastMoveSquare(_ position: Position) -> Bool {
        return position == lastMoveFrom || position == lastMoveTo
    }

    func isHintSquare(_ position: Position) -> Bool {
        return position == hintFrom || position == hintTo
    }
}
