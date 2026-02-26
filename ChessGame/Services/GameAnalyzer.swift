//
//  GameAnalyzer.swift
//  ChessGame
//
//  Post-game analysis: identifies blunders, mistakes, and best moves
//

import Foundation

enum MoveQuality: String {
    case brilliant = "Brilliant"
    case best = "Best"
    case good = "Good"
    case inaccuracy = "Inaccuracy"
    case mistake = "Mistake"
    case blunder = "Blunder"

    var symbol: String {
        switch self {
        case .brilliant: return "!!"
        case .best: return ""
        case .good: return ""
        case .inaccuracy: return "?!"
        case .mistake: return "?"
        case .blunder: return "??"
        }
    }
}

struct AnalyzedMove {
    let moveIndex: Int
    let move: ChessMove
    let quality: MoveQuality
    let evalChange: Int  // centipawn change (negative = bad)
    let bestAlternative: (from: Position, to: Position)?
}

class GameAnalyzer {
    private let ai = ChessAI(difficulty: .hard)

    /// Analyzes a completed game and rates each move
    func analyze(moves: [ChessMove]) -> [AnalyzedMove] {
        var results: [AnalyzedMove] = []
        let board = ChessBoard()

        for (index, move) in moves.enumerated() {
            // Find what the AI thinks is best BEFORE making this move
            let bestMove = ai.getBestMove(board: board)

            // Evaluate position before the move
            let evalBefore = simpleEval(board: board, forColor: board.currentTurn)

            // Make the actual move
            _ = board.makeMove(from: move.from, to: move.to,
                              promotionType: move.promotionPiece ?? .queen)

            // Evaluate after (from opponent's perspective, so negate)
            let evalAfter = -simpleEval(board: board, forColor: board.currentTurn)

            let evalChange = evalAfter - evalBefore

            // Determine quality based on evaluation change
            let quality = classifyMove(evalChange: evalChange)

            var bestAlt: (from: Position, to: Position)?
            if let best = bestMove, (best.from != move.from || best.to != move.to) {
                bestAlt = best
            }

            results.append(AnalyzedMove(
                moveIndex: index,
                move: move,
                quality: quality,
                evalChange: evalChange,
                bestAlternative: bestAlt
            ))
        }

        return results
    }

    private func simpleEval(board: ChessBoard, forColor: PieceColor) -> Int {
        var score = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board.pieceAt(Position(row: row, col: col)) {
                    let value = piece.type.value
                    if piece.color == forColor {
                        score += value
                    } else {
                        score -= value
                    }
                }
            }
        }
        return score
    }

    private func classifyMove(evalChange: Int) -> MoveQuality {
        if evalChange >= 50 {
            return .brilliant
        } else if evalChange >= -10 {
            return .best
        } else if evalChange >= -50 {
            return .good
        } else if evalChange >= -100 {
            return .inaccuracy
        } else if evalChange >= -250 {
            return .mistake
        } else {
            return .blunder
        }
    }
}
