//
//  ChessAI.swift
//  ChessGame
//
//  AI opponent with three difficulty levels using minimax with alpha-beta pruning
//  and piece-square tables for positional evaluation
//

import Foundation

class ChessAI {
    let difficulty: AIDifficulty

    // MARK: - Piece-Square Tables (from white's perspective, row 0 = rank 1)

    private static let pawnTable: [[Int]] = [
        [  0,   0,   0,   0,   0,   0,   0,   0],
        [  5,  10,  10, -20, -20,  10,  10,   5],
        [  5,  -5, -10,   0,   0, -10,  -5,   5],
        [  0,   0,   0,  20,  20,   0,   0,   0],
        [  5,   5,  10,  25,  25,  10,   5,   5],
        [ 10,  10,  20,  30,  30,  20,  10,  10],
        [ 50,  50,  50,  50,  50,  50,  50,  50],
        [  0,   0,   0,   0,   0,   0,   0,   0]
    ]

    private static let knightTable: [[Int]] = [
        [-50, -40, -30, -30, -30, -30, -40, -50],
        [-40, -20,   0,   5,   5,   0, -20, -40],
        [-30,   5,  10,  15,  15,  10,   5, -30],
        [-30,   0,  15,  20,  20,  15,   0, -30],
        [-30,   5,  15,  20,  20,  15,   5, -30],
        [-30,   0,  10,  15,  15,  10,   0, -30],
        [-40, -20,   0,   0,   0,   0, -20, -40],
        [-50, -40, -30, -30, -30, -30, -40, -50]
    ]

    private static let bishopTable: [[Int]] = [
        [-20, -10, -10, -10, -10, -10, -10, -20],
        [-10,   5,   0,   0,   0,   0,   5, -10],
        [-10,  10,  10,  10,  10,  10,  10, -10],
        [-10,   0,  10,  10,  10,  10,   0, -10],
        [-10,   5,   5,  10,  10,   5,   5, -10],
        [-10,   0,   5,  10,  10,   5,   0, -10],
        [-10,   0,   0,   0,   0,   0,   0, -10],
        [-20, -10, -10, -10, -10, -10, -10, -20]
    ]

    private static let rookTable: [[Int]] = [
        [  0,   0,   0,   5,   5,   0,   0,   0],
        [ -5,   0,   0,   0,   0,   0,   0,  -5],
        [ -5,   0,   0,   0,   0,   0,   0,  -5],
        [ -5,   0,   0,   0,   0,   0,   0,  -5],
        [ -5,   0,   0,   0,   0,   0,   0,  -5],
        [ -5,   0,   0,   0,   0,   0,   0,  -5],
        [  5,  10,  10,  10,  10,  10,  10,   5],
        [  0,   0,   0,   0,   0,   0,   0,   0]
    ]

    private static let queenTable: [[Int]] = [
        [-20, -10, -10,  -5,  -5, -10, -10, -20],
        [-10,   0,   5,   0,   0,   0,   0, -10],
        [-10,   5,   5,   5,   5,   5,   0, -10],
        [  0,   0,   5,   5,   5,   5,   0,  -5],
        [ -5,   0,   5,   5,   5,   5,   0,  -5],
        [-10,   0,   5,   5,   5,   5,   0, -10],
        [-10,   0,   0,   0,   0,   0,   0, -10],
        [-20, -10, -10,  -5,  -5, -10, -10, -20]
    ]

    private static let kingMiddlegameTable: [[Int]] = [
        [ 20,  30,  10,   0,   0,  10,  30,  20],
        [ 20,  20,   0,   0,   0,   0,  20,  20],
        [-10, -20, -20, -20, -20, -20, -20, -10],
        [-20, -30, -30, -40, -40, -30, -30, -20],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30]
    ]

    private static let kingEndgameTable: [[Int]] = [
        [-50, -30, -30, -30, -30, -30, -30, -50],
        [-30, -30,   0,   0,   0,   0, -30, -30],
        [-30, -10,  20,  30,  30,  20, -10, -30],
        [-30, -10,  30,  40,  40,  30, -10, -30],
        [-30, -10,  30,  40,  40,  30, -10, -30],
        [-30, -10,  20,  30,  30,  20, -10, -30],
        [-30, -20, -10,   0,   0, -10, -20, -30],
        [-50, -40, -30, -20, -20, -30, -40, -50]
    ]

    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
    }

    func getBestMove(board: ChessBoard) -> (from: Position, to: Position)? {
        let workingBoard = board.copyBoard()

        switch difficulty {
        case .easy:
            return getEasyMove(board: workingBoard)
        case .medium, .hard:
            return getMinimaxMove(board: workingBoard, depth: difficulty.searchDepth)
        }
    }

    // MARK: - Easy AI (Random with basic capture preference)

    private func getEasyMove(board: ChessBoard) -> (from: Position, to: Position)? {
        var captures: [(from: Position, to: Position)] = []
        var quietMoves: [(from: Position, to: Position)] = []

        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        if board.pieceAt(to) != nil {
                            captures.append((from: from, to: to))
                        } else {
                            quietMoves.append((from: from, to: to))
                        }
                    }
                }
            }
        }

        // 60% chance to prefer captures, otherwise random
        if !captures.isEmpty && Double.random(in: 0...1) < 0.6 {
            return captures.randomElement()
        }

        let allMoves = captures + quietMoves
        return allMoves.randomElement()
    }

    // MARK: - Medium/Hard AI (Minimax with Alpha-Beta Pruning)

    private func getMinimaxMove(board: ChessBoard, depth: Int) -> (from: Position, to: Position)? {
        var bestMove: (from: Position, to: Position)?
        var bestScore = Int.min
        var currentAlpha = Int.min

        var allMoves = collectAndOrderMoves(board: board)
        allMoves.shuffle()

        // Sort by estimated value (captures first via MVV-LVA)
        allMoves.sort { a, b in
            moveOrderScore(board: board, from: a.from, to: a.to) >
            moveOrderScore(board: board, from: b.from, to: b.to)
        }

        for move in allMoves {
            if let _ = board.makeMove(from: move.from, to: move.to) {
                let score = -negamax(board: board, depth: depth - 1, alpha: -Int.max, beta: -currentAlpha)
                _ = board.undoLastMove()

                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
                currentAlpha = max(currentAlpha, score)
            }
        }

        return bestMove
    }

    private func negamax(board: ChessBoard, depth: Int, alpha: Int, beta: Int) -> Int {
        if depth == 0 {
            return quiescenceSearch(board: board, alpha: alpha, beta: beta, depth: 4)
        }

        if board.isCheckmate(color: board.currentTurn) {
            return -1000000 - depth
        }

        if board.isStalemate(color: board.currentTurn) || board.isInsufficientMaterial() || board.isDrawByFiftyMoveRule() {
            return 0
        }

        var allMoves = collectAndOrderMoves(board: board)

        if allMoves.isEmpty {
            return evaluatePosition(board: board)
        }

        // Move ordering for better pruning
        allMoves.sort { a, b in
            moveOrderScore(board: board, from: a.from, to: a.to) >
            moveOrderScore(board: board, from: b.from, to: b.to)
        }

        var currentAlpha = alpha

        for move in allMoves {
            if let _ = board.makeMove(from: move.from, to: move.to) {
                let score = -negamax(board: board, depth: depth - 1, alpha: -beta, beta: -currentAlpha)
                _ = board.undoLastMove()

                if score >= beta {
                    return beta
                }
                currentAlpha = max(currentAlpha, score)
            }
        }

        return currentAlpha
    }

    // MARK: - Quiescence Search (search captures at leaf nodes to avoid horizon effect)

    private func quiescenceSearch(board: ChessBoard, alpha: Int, beta: Int, depth: Int) -> Int {
        let standPat = evaluatePosition(board: board)

        if standPat >= beta {
            return beta
        }

        var currentAlpha = max(alpha, standPat)

        if depth == 0 {
            return currentAlpha
        }

        // Only search capture moves
        let captureMoves = collectCaptureMoves(board: board)

        for move in captureMoves {
            if let _ = board.makeMove(from: move.from, to: move.to) {
                let score = -quiescenceSearch(board: board, alpha: -beta, beta: -currentAlpha, depth: depth - 1)
                _ = board.undoLastMove()

                if score >= beta {
                    return beta
                }
                currentAlpha = max(currentAlpha, score)
            }
        }

        return currentAlpha
    }

    // MARK: - Move Collection & Ordering

    private func collectAndOrderMoves(board: ChessBoard) -> [(from: Position, to: Position)] {
        var moves: [(from: Position, to: Position)] = []

        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        moves.append((from: from, to: to))
                    }
                }
            }
        }

        return moves
    }

    private func collectCaptureMoves(board: ChessBoard) -> [(from: Position, to: Position)] {
        var moves: [(from: Position, to: Position)] = []

        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = board.pieceAt(from), piece.color == board.currentTurn {
                    let possibleMoves = board.getPossibleMoves(from: from)
                    for to in possibleMoves {
                        if board.pieceAt(to) != nil || to == board.enPassantTarget {
                            moves.append((from: from, to: to))
                        }
                    }
                }
            }
        }

        return moves
    }

    private func moveOrderScore(board: ChessBoard, from: Position, to: Position) -> Int {
        var score = 0

        // MVV-LVA: Most Valuable Victim - Least Valuable Attacker
        if let victim = board.pieceAt(to) {
            score += victim.type.value * 10
            if let attacker = board.pieceAt(from) {
                score -= attacker.type.value
            }
        }

        // Bonus for pawn promotion
        if let piece = board.pieceAt(from), piece.type == .pawn {
            let promotionRow = piece.color == .white ? 7 : 0
            if to.row == promotionRow {
                score += 800
            }
        }

        return score
    }

    // MARK: - Board Evaluation

    private func evaluatePosition(board: ChessBoard) -> Int {
        var score = 0
        var totalMaterial = 0

        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board.pieceAt(pos) {
                    let materialValue = piece.type.value
                    let positionalValue = getPieceSquareValue(piece: piece, position: pos, board: board)
                    let totalValue = materialValue + positionalValue

                    if piece.color == board.currentTurn {
                        score += totalValue
                    } else {
                        score -= totalValue
                    }

                    if piece.type != .king {
                        totalMaterial += materialValue
                    }
                }
            }
        }

        // Check bonus/penalty
        if board.isInCheck(color: board.currentTurn) {
            score -= 50
        }
        if board.isInCheck(color: board.currentTurn.opposite) {
            score += 50
        }

        return score
    }

    private func getPieceSquareValue(piece: ChessPiece, position: Position, board: ChessBoard) -> Int {
        let row = piece.color == .white ? position.row : (7 - position.row)
        let col = position.col

        switch piece.type {
        case .pawn:
            return ChessAI.pawnTable[row][col]
        case .knight:
            return ChessAI.knightTable[row][col]
        case .bishop:
            return ChessAI.bishopTable[row][col]
        case .rook:
            return ChessAI.rookTable[row][col]
        case .queen:
            return ChessAI.queenTable[row][col]
        case .king:
            let isEndgame = countMaterial(board: board) < 2600
            return isEndgame ? ChessAI.kingEndgameTable[row][col] : ChessAI.kingMiddlegameTable[row][col]
        }
    }

    private func countMaterial(board: ChessBoard) -> Int {
        var total = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board.pieceAt(Position(row: row, col: col)), piece.type != .king && piece.type != .pawn {
                    total += piece.type.value
                }
            }
        }
        return total
    }
}
