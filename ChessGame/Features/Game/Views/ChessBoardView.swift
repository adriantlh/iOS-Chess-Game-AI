//
//  ChessBoardView.swift
//  ChessGame
//
//  Visual representation of the chess board with coordinates and move indicators
//

import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var viewModel: ChessGameViewModel
    @AppStorage("showCoordinates") private var showCoordinates = false

    private let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
    private let ranks = ["1", "2", "3", "4", "5", "6", "7", "8"]

    var body: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height) / 8

            let isBlack = viewModel.gameState.playerColor == .black
            let rows = isBlack ? Array(0..<8) : Array((0..<8).reversed())
            let cols = isBlack ? Array((0..<8).reversed()) : Array(0..<8)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(spacing: 0) {
                        ForEach(Array(cols.enumerated()), id: \.offset) { colIndex, col in
                            let position = Position(row: row, col: col)
                            let isLightSquare = (row + col) % 2 == 0

                            SquareView(
                                row: row,
                                col: col,
                                squareSize: squareSize,
                                piece: viewModel.board.pieceAt(position),
                                isSelected: viewModel.isSquareSelected(position),
                                isPossibleMove: viewModel.isSquarePossibleMove(position),
                                isThreatened: viewModel.isSquareThreatened(position),
                                isInCheck: viewModel.isSquareInCheck(position),
                                isLastMove: viewModel.isLastMoveSquare(position),
                                showRankLabel: showCoordinates && colIndex == 0 ? ranks[row] : nil,
                                showFileLabel: showCoordinates && rowIndex == rows.count - 1 ? files[col] : nil,
                                isLightSquare: isLightSquare,
                                onTap: {
                                    withAnimation(AppAnimation.quick) {
                                        viewModel.handleSquareTap(row: row, col: col)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: BoardStyle.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BoardStyle.cornerRadius)
                    .stroke(AppColors.boardBorder, lineWidth: BoardStyle.borderWidth)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
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
    let isLastMove: Bool
    let showRankLabel: String?
    let showFileLabel: String?
    let isLightSquare: Bool
    let onTap: () -> Void

    private var squareColor: Color {
        isLightSquare ? AppColors.boardLight : AppColors.boardDark
    }

    private var coordinateColor: Color {
        isLightSquare ? AppColors.boardDark : AppColors.boardLight
    }

    private var overlayColor: Color? {
        if isInCheck {
            return AppColors.checkHighlight
        } else if isSelected {
            return AppColors.selectedSquare
        } else if isLastMove {
            return AppColors.lastMoveHighlight
        } else if isThreatened {
            return AppColors.threatenedSquare
        }
        return nil
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(squareColor)

            if let overlay = overlayColor {
                Rectangle()
                    .fill(overlay)
            }

            // Move indicators — empty square: centered dot
            if isPossibleMove && piece == nil {
                Circle()
                    .fill(AppColors.moveIndicator)
                    .frame(width: squareSize * BoardStyle.moveIndicatorRatio,
                           height: squareSize * BoardStyle.moveIndicatorRatio)
                    .frame(width: squareSize, height: squareSize)
            }

            // Capture indicator — ring around the square edge (Lichess-style)
            if isPossibleMove && piece != nil {
                Circle()
                    .stroke(AppColors.captureIndicator, lineWidth: BoardStyle.captureRingWidth)
                    .frame(width: squareSize * BoardStyle.captureRingRatio,
                           height: squareSize * BoardStyle.captureRingRatio)
                    .frame(width: squareSize, height: squareSize)
            }

            // Piece
            if let piece = piece {
                ChessPieceView(piece: piece, size: squareSize)
                    .frame(width: squareSize, height: squareSize)
            }

            // Board coordinates
            if let rank = showRankLabel {
                Text(rank)
                    .font(.system(size: squareSize * BoardStyle.coordinateFontRatio, weight: .bold))
                    .foregroundColor(coordinateColor)
                    .padding(squareSize * 0.05)
            }

            if let file = showFileLabel {
                Text(file)
                    .font(.system(size: squareSize * BoardStyle.coordinateFontRatio, weight: .bold))
                    .foregroundColor(coordinateColor)
                    .frame(width: squareSize, height: squareSize, alignment: .bottomTrailing)
                    .padding(squareSize * 0.05)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .onTapGesture {
            onTap()
        }
    }
}
