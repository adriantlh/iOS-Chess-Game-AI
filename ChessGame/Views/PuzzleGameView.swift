//
//  PuzzleGameView.swift
//  ChessGame
//
//  Puzzle solving interface
//

import SwiftUI
import Combine

class PuzzleViewModel: ObservableObject {
    @Published var board: ChessBoard
    @Published var puzzle: ChessPuzzle
    @Published var currentMoveIndex: Int = 0
    @Published var selectedPosition: Position?
    @Published var possibleMoves: [Position] = []
    @Published var showSuccess = false
    @Published var showError = false
    @Published var puzzleCompleted = false
    @Published var attempts: Int = 0

    init(puzzle: ChessPuzzle) {
        self.puzzle = puzzle
        self.board = ChessBoard()
        setupPuzzlePosition()
    }

    func setupPuzzlePosition() {
        parseFEN(puzzle.fen)
        board.currentTurn = puzzle.sideToMove
    }

    private func parseFEN(_ fen: String) {
        board.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)

        let components = fen.split(separator: " ")
        guard !components.isEmpty else { return }

        let position = String(components[0])
        let ranks = position.split(separator: "/")

        for (index, rank) in ranks.enumerated() {
            let row = 7 - index
            var col = 0

            for char in rank {
                if let emptySquares = Int(String(char)) {
                    col += emptySquares
                } else {
                    if let piece = pieceFromFEN(char) {
                        board.setPiece(piece, at: Position(row: row, col: col))
                    }
                    col += 1
                }
            }
        }
    }

    private func pieceFromFEN(_ char: Character) -> ChessPiece? {
        let color: PieceColor = char.isUppercase ? .white : .black
        let lowercaseChar = char.lowercased().first!

        let type: PieceType
        switch lowercaseChar {
        case "p": type = .pawn
        case "r": type = .rook
        case "n": type = .knight
        case "b": type = .bishop
        case "q": type = .queen
        case "k": type = .king
        default: return nil
        }

        return ChessPiece(type: type, color: color, hasMoved: true)
    }

    func handleSquareTap(row: Int, col: Int) {
        let position = Position(row: row, col: col)

        if let selected = selectedPosition {
            if possibleMoves.contains(position) {
                checkMove(from: selected, to: position)
            } else if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                selectPiece(at: position)
            } else {
                deselectPiece()
            }
        } else {
            if let piece = board.pieceAt(position), piece.color == board.currentTurn {
                selectPiece(at: position)
            }
        }
    }

    private func selectPiece(at position: Position) {
        selectedPosition = position
        possibleMoves = board.getPossibleMoves(from: position)
    }

    private func deselectPiece() {
        selectedPosition = nil
        possibleMoves = []
    }

    private func checkMove(from: Position, to: Position) {
        guard currentMoveIndex < puzzle.solution.count else { return }

        let expectedMove = puzzle.solution[currentMoveIndex]

        if from == expectedMove.from && to == expectedMove.to {
            _ = board.makeMove(from: from, to: to)
            deselectPiece()
            currentMoveIndex += 1
            attempts += 1

            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showSuccess = false

                if self.currentMoveIndex >= self.puzzle.solution.count {
                    self.puzzleCompleted = true
                } else {
                    if self.currentMoveIndex < self.puzzle.solution.count {
                        self.makeOpponentMove()
                    }
                }
            }
        } else {
            attempts += 1
            showError = true
            deselectPiece()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showError = false
            }
        }
    }

    private func makeOpponentMove() {
        guard currentMoveIndex < puzzle.solution.count else { return }

        let move = puzzle.solution[currentMoveIndex]
        _ = board.makeMove(from: move.from, to: move.to)
        currentMoveIndex += 1

        if currentMoveIndex >= puzzle.solution.count {
            puzzleCompleted = true
        }
    }

    func resetPuzzle() {
        setupPuzzlePosition()
        currentMoveIndex = 0
        deselectPiece()
        showSuccess = false
        showError = false
        puzzleCompleted = false
        attempts = 0
    }

    func showHint() {
        if currentMoveIndex < puzzle.solution.count {
            let nextMove = puzzle.solution[currentMoveIndex]
            selectedPosition = nextMove.from
            possibleMoves = [nextMove.to]
        }
    }
}

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
