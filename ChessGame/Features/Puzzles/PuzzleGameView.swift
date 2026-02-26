//
//  PuzzleGameView.swift
//  ChessGame
//
//  Puzzle solving interface
//

import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel: PuzzleViewModel
    let onDismiss: () -> Void

    init(puzzle: ChessPuzzle, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzle: puzzle))
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            AppColors.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()

                    VStack(spacing: Spacing.xs) {
                        Text(viewModel.puzzle.title)
                            .font(AppFonts.headline())
                            .foregroundColor(AppColors.textPrimary)

                        Text(viewModel.puzzle.sideToMove.rawValue.capitalized + " to move")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.resetPuzzle()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .padding(.horizontal, Spacing.lg)

                // Puzzle Info
                HStack {
                    Label(viewModel.puzzle.theme.rawValue, systemImage: viewModel.puzzle.theme.icon)
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(AppColors.accent.opacity(0.2))
                        .cornerRadius(Radii.sm)

                    Text(viewModel.puzzle.difficulty.rawValue)
                        .font(AppFonts.caption())
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(difficultyColor(viewModel.puzzle.difficulty))
                        .cornerRadius(Radii.sm)

                    Spacer()

                    Text("Move \(viewModel.currentMoveIndex + 1)/\(viewModel.puzzle.solution.count)")
                        .font(AppFonts.caption())
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, Spacing.lg)

                // Description
                Text(viewModel.puzzle.description)
                    .font(AppFonts.body())
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)

                // Chess Board
                PuzzleBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, Spacing.md)

                // Controls
                HStack(spacing: Spacing.lg) {
                    Button(action: {
                        viewModel.showHint()
                    }) {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                            Text("Hint")
                                .font(AppFonts.caption(12))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, Spacing.sm)
                        .background(AppColors.warning.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(Radii.md)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button(action: {
                        viewModel.resetPuzzle()
                    }) {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                            Text("Reset")
                                .font(AppFonts.caption(12))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, Spacing.sm)
                        .background(AppColors.warning)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(Radii.md)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()
            }

            // Success overlay
            if viewModel.showSuccess {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AppColors.success)

                    Text("Correct!")
                        .font(AppFonts.title())
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(Spacing.xxl)
                .background(AppColors.overlayDark)
                .cornerRadius(Radii.xl)
                .transition(.scale)
            }

            // Error overlay
            if viewModel.showError {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AppColors.error)

                    Text("Try Again")
                        .font(AppFonts.title())
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(Spacing.xxl)
                .background(AppColors.overlayDark)
                .cornerRadius(Radii.xl)
                .transition(.scale)
            }

            // Completion overlay
            if viewModel.puzzleCompleted {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 72))
                        .foregroundColor(AppColors.completion)
                        .shadow(color: .yellow.opacity(0.4), radius: 10)

                    Text("Puzzle Solved!")
                        .font(AppFonts.display())
                        .foregroundColor(AppColors.textPrimary)

                    Text("Attempts: \(viewModel.attempts)")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: Spacing.lg) {
                        Button(action: {
                            viewModel.resetPuzzle()
                        }) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .background(AppColors.info)
                                .foregroundColor(AppColors.textPrimary)
                                .cornerRadius(Radii.md)
                        }
                        .buttonStyle(ScaleButtonStyle())

                        Button(action: onDismiss) {
                            Text("Back to Menu")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .background(AppColors.success)
                                .foregroundColor(AppColors.textPrimary)
                                .cornerRadius(Radii.md)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, Spacing.xxl)
                }
                .padding(Spacing.xxl)
                .background(AppColors.overlayOpaque)
                .cornerRadius(Radii.xl)
                .transition(.scale)
            }
        }
        .animation(AppAnimation.standard, value: viewModel.showSuccess)
        .animation(AppAnimation.standard, value: viewModel.showError)
        .animation(AppAnimation.standard, value: viewModel.puzzleCompleted)
    }

    func difficultyColor(_ difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .beginner: return AppColors.success
        case .intermediate: return AppColors.info
        case .advanced: return AppColors.warning
        case .expert: return AppColors.error
        }
    }
}

struct PuzzleBoardView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height) / 8

            let isBlack = viewModel.puzzle.sideToMove == .black
            let rows = isBlack ? Array(0..<8) : Array((0..<8).reversed())
            let cols = isBlack ? Array((0..<8).reversed()) : Array(0..<8)

            VStack(spacing: 0) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(cols, id: \.self) { col in
                            PuzzleSquareView(
                                row: row,
                                col: col,
                                squareSize: squareSize,
                                piece: viewModel.board.pieceAt(Position(row: row, col: col)),
                                isSelected: viewModel.selectedPosition == Position(row: row, col: col),
                                isPossibleMove: viewModel.possibleMoves.contains(Position(row: row, col: col)),
                                onTap: {
                                    viewModel.handleSquareTap(row: row, col: col)
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

struct PuzzleSquareView: View {
    let row: Int
    let col: Int
    let squareSize: CGFloat
    let piece: ChessPiece?
    let isSelected: Bool
    let isPossibleMove: Bool
    let onTap: () -> Void

    private var squareColor: Color {
        let isLightSquare = (row + col) % 2 == 0
        return isLightSquare ? AppColors.boardLight : AppColors.boardDark
    }

    private var overlayColor: Color? {
        if isSelected {
            return AppColors.selectedSquare
        } else if isPossibleMove {
            return AppColors.success.opacity(0.25)
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
                    .fill(AppColors.success.opacity(0.4))
                    .frame(width: squareSize * BoardStyle.moveIndicatorRatio,
                           height: squareSize * BoardStyle.moveIndicatorRatio)
            }

            if isPossibleMove && piece != nil {
                Circle()
                    .stroke(AppColors.success.opacity(0.6), lineWidth: BoardStyle.captureRingWidth)
                    .frame(width: squareSize * BoardStyle.captureRingRatio,
                           height: squareSize * BoardStyle.captureRingRatio)
            }

            if let piece = piece {
                ChessPieceView(piece: piece, size: squareSize)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .onTapGesture {
            onTap()
        }
    }
}
