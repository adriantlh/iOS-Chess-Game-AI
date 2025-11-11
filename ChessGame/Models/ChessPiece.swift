//
//  ChessPiece.swift
//  ChessGame
//
//  Defines chess pieces and their properties
//

import Foundation

enum PieceColor: String, Codable {
    case white
    case black

    var opposite: PieceColor {
        return self == .white ? .black : .white
    }
}

enum PieceType: String, Codable {
    case pawn
    case rook
    case knight
    case bishop
    case queen
    case king

    var value: Int {
        switch self {
        case .pawn: return 1
        case .knight: return 3
        case .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 1000
        }
    }

    func symbol(for color: PieceColor) -> String {
        switch self {
        case .pawn: return color == .white ? "♙" : "♟"
        case .rook: return color == .white ? "♖" : "♜"
        case .knight: return color == .white ? "♘" : "♞"
        case .bishop: return color == .white ? "♗" : "♝"
        case .queen: return color == .white ? "♕" : "♛"
        case .king: return color == .white ? "♔" : "♚"
        }
    }
}

struct ChessPiece: Identifiable, Equatable, Codable {
    let id: UUID
    let type: PieceType
    let color: PieceColor
    var hasMoved: Bool

    init(type: PieceType, color: PieceColor, hasMoved: Bool = false) {
        self.id = UUID()
        self.type = type
        self.color = color
        self.hasMoved = hasMoved
    }

    var displaySymbol: String {
        return type.symbol(for: color)
    }

    static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        return lhs.id == rhs.id
    }
}
