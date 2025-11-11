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
        let pieceSymbol = piece.type == .pawn ? "" : piece.type.rawValue.prefix(1).uppercased()
        let capture = capturedPiece != nil ? "x" : ""
        return "\(pieceSymbol)\(capture)\(to.algebraicNotation)"
    }
}
