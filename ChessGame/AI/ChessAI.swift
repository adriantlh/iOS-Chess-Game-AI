//
//  ChessAI.swift
//  ChessGame
//
//  AI opponent with three difficulty levels
//

import Foundation

class ChessAI {
    let difficulty: AIDifficulty

    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
    }

    func getBestMove(board: ChessBoard) -> (from: Position, to: Position)? {
        switch difficulty {
        case .easy:
            return getRandomMove(board: board)
        case .medium, .hard:
            return getMinimaxMove(board: board, depth: difficulty.searchDepth)
        }
    }

    // MARK: - Easy AI (Random Moves)

    private func getRandomMove(board: ChessBoard) -> (from: Position, to: Position)? {
        var allMoves: [(from: Position, to: Position)] = []

        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        allMoves.append((from: from, to: to))
                    }
                }
            }
        }

        guard !allMoves.isEmpty else { return nil }
        return allMoves.randomElement()
    }

    // MARK: - Medium/Hard AI (Minimax with Alpha-Beta Pruning)

    private func getMinimaxMove(board: ChessBoard, depth: Int) -> (from: Position, to: Position)? {
        var bestMove: (from: Position, to: Position)?
        var bestScore = Int.min

        var allMoves: [(from: Position, to: Position)] = []

        // Collect all possible moves
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        allMoves.append((from: from, to: to))
                    }
                }
            }
        }

        // Evaluate each move
        for move in allMoves {
            let simulatedBoard = board.copyBoard()

            if let _ = simulatedBoard.makeMove(from: move.from, to: move.to) {
                let score = -minimax(board: simulatedBoard, depth: depth - 1, alpha: Int.min, beta: Int.max, maximizing: false)

                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
        }

        return bestMove
    }

    private func minimax(board: ChessBoard, depth: Int, alpha: Int, beta: Int, maximizing: Bool) -> Int {
        // Base case: reached max depth or game over
        if depth == 0 {
            return evaluatePosition(board: board)
        }

        if board.isCheckmate(color: board.currentTurn) {
            return maximizing ? -10000 : 10000
        }

        if board.isStalemate(color: board.currentTurn) {
            return 0
        }

        var allMoves: [(from: Position, to: Position)] = []

        // Collect all possible moves
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        allMoves.append((from: from, to: to))
                    }
                }
            }
        }

        if maximizing {
            var maxScore = Int.min
            var currentAlpha = alpha

            for move in allMoves {
                let simulatedBoard = board.copyBoard()

                if let _ = simulatedBoard.makeMove(from: move.from, to: move.to) {
                    let score = minimax(board: simulatedBoard, depth: depth - 1, alpha: currentAlpha, beta: beta, maximizing: false)
                    maxScore = max(maxScore, score)
                    currentAlpha = max(currentAlpha, score)

                    if beta <= currentAlpha {
                        break // Beta cutoff
                    }
                }
            }

            return maxScore
        } else {
            var minScore = Int.max
            var currentBeta = beta

            for move in allMoves {
                let simulatedBoard = board.copyBoard()

                if let _ = simulatedBoard.makeMove(from: move.from, to: move.to) {
                    let score = minimax(board: simulatedBoard, depth: depth - 1, alpha: alpha, beta: currentBeta, maximizing: true)
                    minScore = min(minScore, score)
                    currentBeta = min(currentBeta, score)

                    if currentBeta <= alpha {
                        break // Alpha cutoff
                    }
                }
            }

            return minScore
        }
    }

    // MARK: - Board Evaluation

    private func evaluatePosition(board: ChessBoard) -> Int {
        var score = 0

        // Material value
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board.pieceAt(pos) {
                    let materialValue = piece.type.value
                    let positionalValue = getPositionalValue(piece: piece, position: pos)
                    let totalValue = materialValue + positionalValue

                    if piece.color == board.currentTurn {
                        score += totalValue
                    } else {
                        score -= totalValue
                    }
                }
            }
        }

        // Bonus for having more possible moves (mobility)
        var mobilityScore = 0
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from) {
                    let moves = board.getPossibleMoves(from: from).count
                    if piece.color == board.currentTurn {
                        mobilityScore += moves
                    } else {
                        mobilityScore -= moves
                    }
                }
            }
        }
        score += mobilityScore / 10

        // Penalty for being in check
        if board.isInCheck(color: board.currentTurn) {
            score -= 50
        }
        if board.isInCheck(color: board.currentTurn.opposite) {
            score += 50
        }

        return score
    }

    private func getPositionalValue(piece: ChessPiece, position: Position) -> Int {
        // Simple positional bonuses
        let centerBonus = (3 - abs(position.row - 3.5) + 3 - abs(position.col - 3.5)) / 10

        switch piece.type {
        case .pawn:
            // Pawns are more valuable as they advance
            let advancementBonus = piece.color == .white ? position.row : (7 - position.row)
            return advancementBonus / 10
        case .knight, .bishop:
            // Knights and bishops prefer center
            return Int(centerBonus)
        case .rook:
            // Rooks prefer open files (simplified)
            return 0
        case .queen:
            // Queen prefers center in middlegame
            return Int(centerBonus / 2)
        case .king:
            // King should stay protected in early game
            return 0
        }
    }
}
