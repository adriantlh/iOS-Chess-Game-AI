//
//  ChessBoardView.swift
//  ChessGame
//
//  Visual representation of the chess board with coordinates, move indicators,
//  drag-and-drop, and board theme support
//

import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var viewModel: ChessGameViewModel
    @AppStorage("showCoordinates") private var showCoordinates = false
    @AppStorage("boardTheme") private var boardThemeRaw = BoardThemeType.classic.rawValue
    @AppStorage("pieceStyle") private var pieceStyleRaw = PieceStyle.standard.rawValue

    private let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
    private let ranks = ["1", "2", "3", "4", "5", "6", "7", "8"]

    private var boardTheme: BoardThemeType {
        BoardThemeType(rawValue: boardThemeRaw) ?? .classic
    }

    private var pieceStyle: PieceStyle {
        PieceStyle(rawValue: pieceStyleRaw) ?? .standard
    }

    var body: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height) / 8

            let isBlack = viewModel.gameState.playerColor == .black
            let rows = isBlack ? Array(0..<8) : Array((0..<8).reversed())
            let cols = isBlack ? Array((0..<8).reversed()) : Array(0..<8)

            let displayBoard = viewModel.displayBoard

            ZStack {
                // Board squares and indicators
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
                                    piece: displayBoard.pieceAt(position),
                                    isSelected: viewModel.isSquareSelected(position),
                                    isPossibleMove: viewModel.isSquarePossibleMove(position),
                                    isThreatened: viewModel.isSquareThreatened(position),
                                    isInCheck: viewModel.isSquareInCheck(position),
                                    isLastMove: viewModel.isLastMoveSquare(position),
                                    isHint: viewModel.isHintSquare(position),
                                    showRankLabel: showCoordinates && colIndex == 0 ? ranks[row] : nil,
                                    showFileLabel: showCoordinates && rowIndex == rows.count - 1 ? files[col] : nil,
                                    isLightSquare: isLightSquare,
                                    boardTheme: boardTheme,
                                    pieceStyle: pieceStyle,
                                    isDragSource: viewModel.dragFromPosition == position && viewModel.isDragging,
                                    onTap: {
                                        withAnimation(AppAnimation.quick) {
                                            viewModel.handleSquareTap(row: row, col: col)
                                        }
                                    }
                                )
                                .gesture(
                                    DragGesture(minimumDistance: 10)
                                        .onChanged { value in
                                            if !viewModel.isDragging {
                                                viewModel.handleDragStart(row: row, col: col)
                                            }
                                            viewModel.dragOffset = value.translation
                                        }
                                        .onEnded { value in
                                            let colOffset = isBlack
                                                ? -Int(round(value.translation.width / squareSize))
                                                : Int(round(value.translation.width / squareSize))
                                            let rowOffset = isBlack
                                                ? Int(round(value.translation.height / squareSize))
                                                : -Int(round(value.translation.height / squareSize))

                                            let targetRow = row + rowOffset
                                            let targetCol = col + colOffset
                                            viewModel.handleDragEnd(toRow: targetRow, toCol: targetCol)
                                        }
                                )
                            }
                        }
                    }
                }

                // Dragged piece overlay
                if viewModel.isDragging, let dragFrom = viewModel.dragFromPosition,
                   let piece = viewModel.board.pieceAt(dragFrom) {
                    let originX: CGFloat
                    let originY: CGFloat

                    if isBlack {
                        originX = CGFloat(7 - dragFrom.col) * squareSize + squareSize / 2
                        originY = CGFloat(dragFrom.row) * squareSize + squareSize / 2
                    } else {
                        originX = CGFloat(dragFrom.col) * squareSize + squareSize / 2
                        originY = CGFloat(7 - dragFrom.row) * squareSize + squareSize / 2
                    }

                    ChessPieceView(piece: piece, size: squareSize, pieceStyle: pieceStyle)
                        .position(
                            x: originX + viewModel.dragOffset.width,
                            y: originY + viewModel.dragOffset.height
                        )
                        .scaleEffect(1.2)
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
                        .zIndex(100)
                        .allowsHitTesting(false)
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
    let isHint: Bool
    let showRankLabel: String?
    let showFileLabel: String?
    let isLightSquare: Bool
    let boardTheme: BoardThemeType
    let pieceStyle: PieceStyle
    let isDragSource: Bool
    let onTap: () -> Void

    private var squareColor: Color {
        isLightSquare ? boardTheme.lightSquare : boardTheme.darkSquare
    }

    private var coordinateColor: Color {
        isLightSquare ? boardTheme.darkSquare : boardTheme.lightSquare
    }

    private var overlayColor: Color? {
        if isInCheck {
            return AppColors.checkHighlight
        } else if isSelected {
            return AppColors.selectedSquare
        } else if isHint {
            return AppColors.success.opacity(0.4)
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

            // Piece (hidden when being dragged)
            if let piece = piece, !isDragSource {
                ChessPieceView(piece: piece, size: squareSize, pieceStyle: pieceStyle)
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
