//
//  ChessBoardView.swift
//  ChessGame
//
//  Visual representation of the chess board
//

import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var viewModel: ChessGameViewModel

    var body: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height) / 8

            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            SquareView(
                                row: row,
                                col: col,
                                squareSize: squareSize,
                                piece: viewModel.board.pieceAt(Position(row: row, col: col)),
                                isSelected: viewModel.isSquareSelected(Position(row: row, col: col)),
                                isPossibleMove: viewModel.isSquarePossibleMove(Position(row: row, col: col)),
                                isThreatened: viewModel.isSquareThreatened(Position(row: row, col: col)),
                                isInCheck: viewModel.isSquareInCheck(Position(row: row, col: col)),
                                onTap: {
                                    viewModel.handleSquareTap(row: row, col: col)
                                }
                            )
                        }
                    }
                }
            }
            .frame(width: squareSize * 8, height: squareSize * 8)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct SquareView: View {
    let row: Int
    let col: Int
    let squareSize: CGFloat
    let piece: ChessPiece?
    let isSelected: Bool
    let isPossibleMove: Bool
    let isThreatened: Bool
    let isInCheck: Bool
    let onTap: () -> Void

    private var squareColor: Color {
        let isLightSquare = (row + col) % 2 == 0
        return isLightSquare ? Color(red: 0.93, green: 0.85, blue: 0.72) : Color(red: 0.71, green: 0.53, blue: 0.39)
    }

    private var overlayColor: Color? {
        if isInCheck {
            return Color.red.opacity(0.6)
        } else if isSelected {
            return Color.blue.opacity(0.4)
        } else if isThreatened {
            return Color.orange.opacity(0.5)
        } else if isPossibleMove {
            return Color.green.opacity(0.3)
        }
        return nil
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(squareColor)

            if let overlay = overlayColor {
                Rectangle()
                    .fill(overlay)
            }

            if isPossibleMove && piece == nil {
                Circle()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: squareSize * 0.3, height: squareSize * 0.3)
            }

            if let piece = piece {
                ChessPieceView(piece: piece)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .onTapGesture {
            onTap()
        }
    }
}
