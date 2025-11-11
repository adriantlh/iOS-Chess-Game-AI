//
//  ChessMove.swift
//  ChessGame
//
//  Represents a chess move and associated data
//

import Foundation

struct Position: Equatable, Codable, Hashable {
    let row: Int
    let col: Int

    var isValid: Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }

    func offset(row: Int, col: Int) -> Position {
        return Position(row: self.row + row, col: self.col + col)
    }

    var algebraicNotation: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let ranks = ["1", "2", "3", "4", "5", "6", "7", "8"]
        return "\(files[col])\(ranks[row])"
    }
}

struct ChessMove: Codable {
    let from: Position
    let to: Position
    let piece: ChessPiece
    let capturedPiece: ChessPiece?
    let isEnPassant: Bool
    let isCastling: Bool
    let isPromotion: Bool
    let promotionPiece: PieceType?

    init(from: Position, to: Position, piece: ChessPiece, capturedPiece: ChessPiece? = nil,
         isEnPassant: Bool = false, isCastling: Bool = false, isPromotion: Bool = false, promotionPiece: PieceType? = nil) {
        self.from = from
        self.to = to
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.isEnPassant = isEnPassant
        self.isCastling = isCastling
        self.isPromotion = isPromotion
        self.promotionPiece = promotionPiece
    }

    var notation: String {
        if isCastling {
            return to.col > from.col ? "O-O" : "O-O-O"
        }

        let pieceSymbol = piece.type == .pawn ? "" : piece.type.rawValue.prefix(1).uppercased()
        let fromSquare = piece.type == .pawn && capturedPiece != nil ? from.algebraicNotation.prefix(1) : ""
        let capture = capturedPiece != nil || isEnPassant ? "x" : ""
        let promotion = isPromotion ? "=\(promotionPiece?.rawValue.prefix(1).uppercased() ?? "Q")" : ""

        return "\(pieceSymbol)\(fromSquare)\(capture)\(to.algebraicNotation)\(promotion)"
    }

    func notationWithCheck(isCheck: Bool, isCheckmate: Bool) -> String {
        var move = notation
        if isCheckmate {
            move += "#"
        } else if isCheck {
            move += "+"
        }
        return move
    }
}

struct GameRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let gameMode: GameMode
    let playerColor: PieceColor?
    let aiDifficulty: AIDifficulty?
    let moves: [ChessMove]
    let result: GameResult
    let timeControl: TimeControl?

    init(id: UUID = UUID(), date: Date = Date(), gameMode: GameMode,
         playerColor: PieceColor? = nil, aiDifficulty: AIDifficulty? = nil,
         moves: [ChessMove], result: GameResult, timeControl: TimeControl? = nil) {
        self.id = id
        self.date = date
        self.gameMode = gameMode
        self.playerColor = playerColor
        self.aiDifficulty = aiDifficulty
        self.moves = moves
        self.result = result
        self.timeControl = timeControl
    }

    var displayTitle: String {
        if gameMode == .playerVsAI {
            return "vs AI (\(aiDifficulty?.rawValue ?? ""))"
        } else {
            return "Player vs Player"
        }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum GameResult: String, Codable {
    case whiteWins = "White Wins"
    case blackWins = "Black Wins"
    case draw = "Draw"
    case stalemate = "Stalemate"
    case inProgress = "In Progress"
}
