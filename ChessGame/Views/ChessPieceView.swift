//
//  ChessPieceView.swift
//  ChessGame
//
//  Visual representation of a chess piece with proper styling
//

import SwiftUI

struct ChessPieceView: View {
    let piece: ChessPiece
    let size: CGFloat

    var body: some View {
        Text(piece.displaySymbol)
            .font(.system(size: size * 0.78))
            .foregroundColor(piece.color == .white
                ? Color(red: 0.98, green: 0.98, blue: 0.95)
                : Color(red: 0.12, green: 0.12, blue: 0.12))
            .shadow(color: piece.color == .white
                ? .black.opacity(0.6) : .white.opacity(0.3),
                radius: 1.5, x: 0, y: 1)
            .shadow(color: piece.color == .white
                ? .black.opacity(0.3) : .white.opacity(0.15),
                radius: 0.5, x: 0, y: 0)
    }
}
