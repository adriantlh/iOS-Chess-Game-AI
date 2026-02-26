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
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        viewModel.handleSquareTap(row: row, col: col)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.5), lineWidth: 2)
            )
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
        isLightSquare
            ? Color(red: 0.93, green: 0.85, blue: 0.72)
            : Color(red: 0.71, green: 0.53, blue: 0.39)
    }

    private var coordinateColor: Color {
        isLightSquare
            ? Color(red: 0.71, green: 0.53, blue: 0.39)
            : Color(red: 0.93, green: 0.85, blue: 0.72)
    }

    private var overlayColor: Color? {
        if isInCheck {
            return Color.red.opacity(0.6)
        } else if isSelected {
            return Color(red: 0.3, green: 0.5, blue: 0.8).opacity(0.5)
        } else if isLastMove {
            return Color(red: 0.8, green: 0.75, blue: 0.2).opacity(0.4)
        } else if isThreatened {
            return Color.orange.opacity(0.45)
        } else if isPossibleMove && piece != nil {
            // Capture indicator - handled separately below
            return nil
        } else if isPossibleMove {
            return nil
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

            // Move indicators
            if isPossibleMove && piece == nil {
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: squareSize * 0.3, height: squareSize * 0.3)
                    .frame(width: squareSize, height: squareSize)
            }

            if isPossibleMove && piece != nil {
                // Capture indicator: corner triangles
                CaptureIndicator(size: squareSize)
            }

            // Piece
            if let piece = piece {
                ChessPieceView(piece: piece, size: squareSize)
                    .frame(width: squareSize, height: squareSize)
            }

            // Board coordinates
            if let rank = showRankLabel {
                Text(rank)
                    .font(.system(size: squareSize * 0.18, weight: .bold))
                    .foregroundColor(coordinateColor)
                    .padding(squareSize * 0.05)
            }

            if let file = showFileLabel {
                Text(file)
                    .font(.system(size: squareSize * 0.18, weight: .bold))
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

struct CaptureIndicator: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Four corner triangles to indicate capture
            ForEach(0..<4, id: \.self) { corner in
                Triangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: size * 0.22, height: size * 0.22)
                    .rotationEffect(.degrees(Double(corner) * 90))
                    .offset(
                        x: corner == 0 || corner == 3 ? -size * 0.39 : size * 0.39,
                        y: corner == 0 || corner == 1 ? -size * 0.39 : size * 0.39
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
