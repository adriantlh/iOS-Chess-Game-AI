//
//  ChessBoard.swift
//  ChessGame
//
//  Core chess board logic including move validation, check detection, and game state
//

import Foundation
import Combine

class ChessBoard: ObservableObject, Codable {
    @Published var board: [[ChessPiece?]]
    var currentTurn: PieceColor
    var moveHistory: [ChessMove]
    var enPassantTarget: Position?
    var halfMoveClock: Int

    enum CodingKeys: String, CodingKey {
        case board, currentTurn, moveHistory, enPassantTarget, halfMoveClock
    }

    init() {
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.currentTurn = .white
        self.moveHistory = []
        self.enPassantTarget = nil
        self.halfMoveClock = 0
        setupInitialBoard()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode([[ChessPiece?]].self, forKey: .board)
        self.currentTurn = try container.decode(PieceColor.self, forKey: .currentTurn)
        self.moveHistory = try container.decode([ChessMove].self, forKey: .moveHistory)
        self.enPassantTarget = try container.decodeIfPresent(Position.self, forKey: .enPassantTarget)
        self.halfMoveClock = try container.decodeIfPresent(Int.self, forKey: .halfMoveClock) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(currentTurn, forKey: .currentTurn)
        try container.encode(moveHistory, forKey: .moveHistory)
        try container.encode(enPassantTarget, forKey: .enPassantTarget)
        try container.encode(halfMoveClock, forKey: .halfMoveClock)
    }

    func setupInitialBoard() {
        // Clear board
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)

        // Set up pawns
        for col in 0..<8 {
            board[1][col] = ChessPiece(type: .pawn, color: .white)
            board[6][col] = ChessPiece(type: .pawn, color: .black)
        }

        // Set up white pieces
        board[0][0] = ChessPiece(type: .rook, color: .white)
        board[0][1] = ChessPiece(type: .knight, color: .white)
        board[0][2] = ChessPiece(type: .bishop, color: .white)
        board[0][3] = ChessPiece(type: .queen, color: .white)
        board[0][4] = ChessPiece(type: .king, color: .white)
        board[0][5] = ChessPiece(type: .bishop, color: .white)
        board[0][6] = ChessPiece(type: .knight, color: .white)
        board[0][7] = ChessPiece(type: .rook, color: .white)

        // Set up black pieces
        board[7][0] = ChessPiece(type: .rook, color: .black)
        board[7][1] = ChessPiece(type: .knight, color: .black)
        board[7][2] = ChessPiece(type: .bishop, color: .black)
        board[7][3] = ChessPiece(type: .queen, color: .black)
        board[7][4] = ChessPiece(type: .king, color: .black)
        board[7][5] = ChessPiece(type: .bishop, color: .black)
        board[7][6] = ChessPiece(type: .knight, color: .black)
        board[7][7] = ChessPiece(type: .rook, color: .black)

        currentTurn = .white
        moveHistory = []
        enPassantTarget = nil
        halfMoveClock = 0
    }

    func pieceAt(_ position: Position) -> ChessPiece? {
        guard position.isValid else { return nil }
        return board[position.row][position.col]
    }

    func setPiece(_ piece: ChessPiece?, at position: Position) {
        guard position.isValid else { return }
        board[position.row][position.col] = piece
    }

    // MARK: - Move Validation

    func isValidMove(from: Position, to: Position) -> Bool {
        guard let piece = pieceAt(from), piece.color == currentTurn else { return false }
        guard to.isValid else { return false }

        // Can't capture own piece
        if let targetPiece = pieceAt(to), targetPiece.color == piece.color {
            return false
        }

        // Check piece-specific movement rules
        if !isValidPieceMove(piece: piece, from: from, to: to) {
            return false
        }

        // Check if move would put own king in check
        return !wouldMoveResultInCheck(from: from, to: to, color: piece.color)
    }

    func isValidPieceMove(piece: ChessPiece, from: Position, to: Position) -> Bool {
        switch piece.type {
        case .pawn:
            return isValidPawnMove(piece: piece, from: from, to: to)
        case .rook:
            return isValidRookMove(from: from, to: to)
        case .knight:
            return isValidKnightMove(from: from, to: to)
        case .bishop:
            return isValidBishopMove(from: from, to: to)
        case .queen:
            return isValidQueenMove(from: from, to: to)
        case .king:
            return isValidKingMove(piece: piece, from: from, to: to)
        }
    }

    func isValidPawnMove(piece: ChessPiece, from: Position, to: Position) -> Bool {
        let direction = piece.color == .white ? 1 : -1
        let startRow = piece.color == .white ? 1 : 6
        let rowDiff = to.row - from.row
        let colDiff = abs(to.col - from.col)

        // Forward move
        if colDiff == 0 {
            if rowDiff == direction && pieceAt(to) == nil {
                return true
            }
            // Double move from starting position
            if rowDiff == 2 * direction && from.row == startRow && pieceAt(to) == nil {
                let intermediatePos = Position(row: from.row + direction, col: from.col)
                return pieceAt(intermediatePos) == nil
            }
        }

        // Diagonal capture
        if colDiff == 1 && rowDiff == direction {
            if let targetPiece = pieceAt(to), targetPiece.color != piece.color {
                return true
            }
            // En passant
            if to == enPassantTarget {
                return true
            }
        }

        return false
    }

    func isValidRookMove(from: Position, to: Position) -> Bool {
        if from.row != to.row && from.col != to.col {
            return false
        }
        return isPathClear(from: from, to: to)
    }

    func isValidKnightMove(from: Position, to: Position) -> Bool {
        let rowDiff = abs(to.row - from.row)
        let colDiff = abs(to.col - from.col)
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)
    }

    func isValidBishopMove(from: Position, to: Position) -> Bool {
        if abs(to.row - from.row) != abs(to.col - from.col) {
            return false
        }
        return isPathClear(from: from, to: to)
    }

    func isValidQueenMove(from: Position, to: Position) -> Bool {
        return isValidRookMove(from: from, to: to) || isValidBishopMove(from: from, to: to)
    }

    func isValidKingMove(piece: ChessPiece, from: Position, to: Position) -> Bool {
        let rowDiff = abs(to.row - from.row)
        let colDiff = abs(to.col - from.col)

        // Normal king move (one square in any direction)
        if rowDiff <= 1 && colDiff <= 1 {
            return true
        }

        // Castling
        if !piece.hasMoved && rowDiff == 0 && colDiff == 2 {
            return canCastle(from: from, to: to, color: piece.color)
        }

        return false
    }

    func isPathClear(from: Position, to: Position) -> Bool {
        let rowDir = (to.row - from.row).signum()
        let colDir = (to.col - from.col).signum()

        var current = Position(row: from.row + rowDir, col: from.col + colDir)
        while current != to {
            if pieceAt(current) != nil {
                return false
            }
            current = Position(row: current.row + rowDir, col: current.col + colDir)
        }
        return true
    }

    func canCastle(from: Position, to: Position, color: PieceColor) -> Bool {
        guard let king = pieceAt(from), king.type == .king, !king.hasMoved else { return false }

        let direction = to.col > from.col ? 1 : -1
        let rookCol = direction == 1 ? 7 : 0
        let rookPos = Position(row: from.row, col: rookCol)

        guard let rook = pieceAt(rookPos), rook.type == .rook, !rook.hasMoved else { return false }

        // Check path is clear
        let start = min(from.col, rookCol)
        let end = max(from.col, rookCol)
        for col in (start + 1)..<end {
            if pieceAt(Position(row: from.row, col: col)) != nil {
                return false
            }
        }

        // King can't castle through check
        for col in [from.col, from.col + direction, to.col] {
            let pos = Position(row: from.row, col: col)
            if isSquareUnderAttack(pos, by: color.opposite) {
                return false
            }
        }

        return true
    }

    // MARK: - Check Detection

    func isSquareUnderAttack(_ position: Position, by color: PieceColor) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = pieceAt(pos), piece.color == color {
                    if isValidPieceMove(piece: piece, from: pos, to: position) {
                        // For kings, only consider normal moves (not castling) to avoid recursion
                        if piece.type != .king || (abs(position.row - row) <= 1 && abs(position.col - col) <= 1) {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    func findKing(color: PieceColor) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = pieceAt(pos), piece.type == .king, piece.color == color {
                    return pos
                }
            }
        }
        return nil
    }

    func isInCheck(color: PieceColor) -> Bool {
        guard let kingPos = findKing(color: color) else { return false }
        return isSquareUnderAttack(kingPos, by: color.opposite)
    }

    func wouldMoveResultInCheck(from: Position, to: Position, color: PieceColor) -> Bool {
        // Simulate the move
        let originalPiece = pieceAt(from)
        let capturedPiece = pieceAt(to)

        // Handle en passant simulation
        var enPassantCapturePos: Position?
        if let piece = originalPiece, piece.type == .pawn, to == enPassantTarget {
            let captureRow = piece.color == .white ? to.row - 1 : to.row + 1
            enPassantCapturePos = Position(row: captureRow, col: to.col)
        }

        setPiece(originalPiece, at: to)
        setPiece(nil, at: from)
        var enPassantCaptured: ChessPiece?
        if let epPos = enPassantCapturePos {
            enPassantCaptured = pieceAt(epPos)
            setPiece(nil, at: epPos)
        }

        let inCheck = isInCheck(color: color)

        // Undo the simulation
        setPiece(originalPiece, at: from)
        setPiece(capturedPiece, at: to)
        if let epPos = enPassantCapturePos {
            setPiece(enPassantCaptured, at: epPos)
        }

        return inCheck
    }

    // MARK: - Checkmate and Stalemate

    func isCheckmate(color: PieceColor) -> Bool {
        if !isInCheck(color: color) {
            return false
        }
        return !hasLegalMoves(color: color)
    }

    func isStalemate(color: PieceColor) -> Bool {
        if isInCheck(color: color) {
            return false
        }
        return !hasLegalMoves(color: color)
    }

    func hasLegalMoves(color: PieceColor) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                if let piece = pieceAt(from), piece.color == color {
                    for toRow in 0..<8 {
                        for toCol in 0..<8 {
                            let to = Position(row: toRow, col: toCol)
                            if isValidMove(from: from, to: to) {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    // MARK: - Draw Detection

    func isDrawByFiftyMoveRule() -> Bool {
        return halfMoveClock >= 100
    }

    func isInsufficientMaterial() -> Bool {
        var whitePieces: [PieceType] = []
        var blackPieces: [PieceType] = []

        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = pieceAt(Position(row: row, col: col)) {
                    if piece.color == .white {
                        whitePieces.append(piece.type)
                    } else {
                        blackPieces.append(piece.type)
                    }
                }
            }
        }

        // King vs King
        if whitePieces.count == 1 && blackPieces.count == 1 {
            return true
        }

        // King + Bishop vs King or King + Knight vs King
        if whitePieces.count == 1 && blackPieces.count == 2 {
            let nonKing = blackPieces.first { $0 != .king }
            if nonKing == .bishop || nonKing == .knight { return true }
        }
        if blackPieces.count == 1 && whitePieces.count == 2 {
            let nonKing = whitePieces.first { $0 != .king }
            if nonKing == .bishop || nonKing == .knight { return true }
        }

        return false
    }

    // MARK: - Move Execution

    func isPromotionMove(from: Position, to: Position) -> Bool {
        guard let piece = pieceAt(from), piece.type == .pawn else { return false }
        return (piece.color == .white && to.row == 7) || (piece.color == .black && to.row == 0)
    }

    func makeMove(from: Position, to: Position, promotionType: PieceType = .queen) -> ChessMove? {
        guard isValidMove(from: from, to: to) else { return nil }
        guard var piece = pieceAt(from) else { return nil }

        let originalPiece = piece
        var capturedPiece = pieceAt(to)
        var isEnPassant = false
        var isCastling = false
        var isPromotion = false
        var promotionPiece: PieceType? = nil

        // Handle en passant
        if piece.type == .pawn && to == enPassantTarget {
            isEnPassant = true
            let captureRow = piece.color == .white ? to.row - 1 : to.row + 1
            let capturePos = Position(row: captureRow, col: to.col)
            capturedPiece = pieceAt(capturePos)
            setPiece(nil, at: capturePos)
        }

        // Handle castling
        if piece.type == .king && abs(to.col - from.col) == 2 {
            isCastling = true
            let direction = to.col > from.col ? 1 : -1
            let rookFromCol = direction == 1 ? 7 : 0
            let rookToCol = from.col + direction

            if var rook = pieceAt(Position(row: from.row, col: rookFromCol)) {
                rook.hasMoved = true
                setPiece(rook, at: Position(row: from.row, col: rookToCol))
                setPiece(nil, at: Position(row: from.row, col: rookFromCol))
            }
        }

        // Handle pawn promotion
        if piece.type == .pawn && ((piece.color == .white && to.row == 7) || (piece.color == .black && to.row == 0)) {
            isPromotion = true
            promotionPiece = promotionType
            piece = ChessPiece(type: promotionType, color: piece.color, hasMoved: true)
        } else {
            piece.hasMoved = true
        }

        // Update half-move clock (reset on pawn move or capture)
        if originalPiece.type == .pawn || capturedPiece != nil {
            halfMoveClock = 0
        } else {
            halfMoveClock += 1
        }

        // Update en passant target
        if originalPiece.type == .pawn && abs(to.row - from.row) == 2 {
            let direction = originalPiece.color == .white ? 1 : -1
            enPassantTarget = Position(row: from.row + direction, col: from.col)
        } else {
            enPassantTarget = nil
        }

        // Execute move
        setPiece(piece, at: to)
        setPiece(nil, at: from)

        let move = ChessMove(from: from, to: to, piece: piece, originalPiece: originalPiece,
                            capturedPiece: capturedPiece,
                            isEnPassant: isEnPassant, isCastling: isCastling,
                            isPromotion: isPromotion, promotionPiece: promotionPiece)
        moveHistory.append(move)

        // Switch turns
        currentTurn = currentTurn.opposite

        return move
    }

    // MARK: - Threatened Pieces Detection

    func getThreatenedPieces(color: PieceColor) -> Set<Position> {
        var threatenedPositions = Set<Position>()

        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = pieceAt(pos), piece.color == color {
                    if isSquareUnderAttack(pos, by: color.opposite) {
                        threatenedPositions.insert(pos)
                    }
                }
            }
        }

        return threatenedPositions
    }

    func getPossibleMoves(from: Position) -> [Position] {
        var moves: [Position] = []
        guard pieceAt(from) != nil else { return moves }

        for row in 0..<8 {
            for col in 0..<8 {
                let to = Position(row: row, col: col)
                if isValidMove(from: from, to: to) {
                    moves.append(to)
                }
            }
        }

        return moves
    }

    // MARK: - Undo Move

    func undoLastMove() -> Bool {
        guard let lastMove = moveHistory.popLast() else { return false }

        // Switch turn back
        currentTurn = currentTurn.opposite

        // Restore original piece at its starting position
        setPiece(lastMove.originalPiece, at: lastMove.from)

        // Restore captured piece at destination (nil for en passant target square)
        if lastMove.isEnPassant {
            setPiece(nil, at: lastMove.to)
            let captureRow = lastMove.originalPiece.color == .white ? lastMove.to.row - 1 : lastMove.to.row + 1
            setPiece(lastMove.capturedPiece, at: Position(row: captureRow, col: lastMove.to.col))
        } else {
            setPiece(lastMove.capturedPiece, at: lastMove.to)
        }

        // Undo castling rook move
        if lastMove.isCastling {
            let direction = lastMove.to.col > lastMove.from.col ? 1 : -1
            let rookFromCol = direction == 1 ? 7 : 0
            let rookToCol = lastMove.from.col + direction

            let rook = ChessPiece(type: .rook, color: lastMove.originalPiece.color, hasMoved: false)
            setPiece(rook, at: Position(row: lastMove.from.row, col: rookFromCol))
            setPiece(nil, at: Position(row: lastMove.from.row, col: rookToCol))
        }

        // Restore en passant target from previous move
        if !moveHistory.isEmpty {
            let prevMove = moveHistory[moveHistory.count - 1]
            if prevMove.originalPiece.type == .pawn && abs(prevMove.to.row - prevMove.from.row) == 2 {
                let direction = prevMove.originalPiece.color == .white ? 1 : -1
                enPassantTarget = Position(row: prevMove.from.row + direction, col: prevMove.from.col)
            } else {
                enPassantTarget = nil
            }
        } else {
            enPassantTarget = nil
        }

        // Restore half-move clock (approximate - recalculate from history)
        halfMoveClock = 0
        for move in moveHistory.reversed() {
            if move.originalPiece.type == .pawn || move.capturedPiece != nil {
                break
            }
            halfMoveClock += 1
        }

        return true
    }

    // MARK: - Board Evaluation (for AI)

    func evaluateBoard() -> Int {
        var score = 0

        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = pieceAt(pos) {
                    let value = piece.type.value
                    score += piece.color == .white ? value : -value
                }
            }
        }

        return score
    }

    func copyBoard() -> ChessBoard {
        let newBoard = ChessBoard()
        newBoard.board = self.board
        newBoard.currentTurn = self.currentTurn
        newBoard.moveHistory = self.moveHistory
        newBoard.enPassantTarget = self.enPassantTarget
        newBoard.halfMoveClock = self.halfMoveClock
        return newBoard
    }
}
