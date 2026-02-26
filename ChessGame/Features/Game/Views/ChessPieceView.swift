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
    var pieceStyle: PieceStyle = .standard

    var body: some View {
        Text(pieceStyle.symbol(type: piece.type, color: piece.color))
            .font(.system(size: size * BoardStyle.pieceScale))
            .foregroundColor(piece.color == .white ? AppColors.whitePiece : AppColors.blackPiece)
            .shadow(color: piece.color == .white
                ? .black.opacity(0.6) : .white.opacity(0.3),
                radius: 1.5, x: 0, y: 1)
            .shadow(color: piece.color == .white
                ? .black.opacity(0.3) : .white.opacity(0.15),
                radius: 0.5, x: 0, y: 0)
    }
}
