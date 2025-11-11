//
//  ChessPieceView.swift
//  ChessGame
//
//  Visual representation of a chess piece
//

import SwiftUI

struct ChessPieceView: View {
    let piece: ChessPiece

    var body: some View {
        Text(piece.displaySymbol)
            .font(.system(size: 40))
            .foregroundColor(piece.color == .white ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.1, green: 0.1, blue: 0.1))
            .shadow(color: piece.color == .white ? .black.opacity(0.5) : .clear, radius: 1, x: 0, y: 0)
    }
}
