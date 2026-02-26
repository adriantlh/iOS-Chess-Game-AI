//
//  HintEngine.swift
//  ChessGame
//
//  Analyzes board positions to suggest the best move using the AI engine
//

import Foundation

struct HintResult {
    let from: Position
    let to: Position
    let description: String
    let value: Int  // centipawn evaluation
}

class HintEngine {
    private let ai = ChessAI(difficulty: .hard)

    /// Analyzes the current board position and returns the best move hint
    func getBestMoveHint(board: ChessBoard) -> HintResult? {
        let workingBoard = board.copyBoard()

        guard let bestMove = ai.getBestMove(board: workingBoard) else { return nil }

        let description = buildDescription(board: board, from: bestMove.from, to: bestMove.to)
        let value = evaluateMove(board: board, from: bestMove.from, to: bestMove.to)

        return HintResult(
            from: bestMove.from,
            to: bestMove.to,
            description: description,
            value: value
        )
    }

    /// Ranks all legal moves for the current player from best to worst
    func rankMoves(board: ChessBoard) -> [HintResult] {
        let workingBoard = board.copyBoard()
        var results: [HintResult] = []

        // Collect all legal moves
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                guard let piece = workingBoard.pieceAt(from),
                      piece.color == workingBoard.currentTurn else { continue }

                let moves = workingBoard.getPossibleMoves(from: from)
                for to in moves {
                    let description = buildDescription(board: workingBoard, from: from, to: to)
                    let value = evaluateMove(board: workingBoard, from: from, to: to)
                    results.append(HintResult(from: from, to: to, description: description, value: value))
                }
            }
        }

        return results.sorted { $0.value > $1.value }
    }

    private func evaluateMove(board: ChessBoard, from: Position, to: Position) -> Int {
        let workingBoard = board.copyBoard()

        let evalBefore = evaluateForCurrentPlayer(board: workingBoard)

        if let _ = workingBoard.makeMove(from: from, to: to) {
            // After making a move, currentTurn flips, so we negate
            let evalAfter = -evaluateForCurrentPlayer(board: workingBoard)
            _ = workingBoard.undoLastMove()
            return evalAfter - evalBefore
        }

        return 0
    }

    private func evaluateForCurrentPlayer(board: ChessBoard) -> Int {
        var score = 0
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board.pieceAt(pos) {
                    let value = piece.type.value
                    if piece.color == board.currentTurn {
                        score += value
                    } else {
                        score -= value
                    }
                }
            }
        }
        return score
    }

    private func buildDescription(board: ChessBoard, from: Position, to: Position) -> String {
        guard let piece = board.pieceAt(from) else { return "" }

        let pieceName = piece.type.rawValue.capitalized

        if let captured = board.pieceAt(to) {
            let capturedName = captured.type.rawValue.capitalized
            let gain = captured.type.value - piece.type.value
            if gain > 0 {
                return "\(pieceName) captures \(capturedName) (+\(gain / 100) material)"
            }
            return "\(pieceName) captures \(capturedName)"
        }

        // Check for castling
        if piece.type == .king && abs(to.col - from.col) == 2 {
            return to.col > from.col ? "Kingside castle" : "Queenside castle"
        }

        // Check if move gives check
        let workingBoard = board.copyBoard()
        if let _ = workingBoard.makeMove(from: from, to: to) {
            if workingBoard.isInCheck(color: workingBoard.currentTurn) {
                _ = workingBoard.undoLastMove()
                return "\(pieceName) to \(to.algebraicNotation) with check"
            }
            _ = workingBoard.undoLastMove()
        }

        return "\(pieceName) to \(to.algebraicNotation)"
    }
}
