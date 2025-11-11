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
            .foregroundColor(piece.color == .white ? .white : .black)
            .shadow(color: piece.color == .white ? .black.opacity(0.3) : .white.opacity(0.3), radius: 2)
    }
}
