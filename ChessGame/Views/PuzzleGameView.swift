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
        // Parse FEN notation to set up puzzle position
        parseFEN(puzzle.fen)
        board.currentTurn = puzzle.sideToMove
    }

    private func parseFEN(_ fen: String) {
        // Clear the board first
        board.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)

        let components = fen.split(separator: " ")
        guard !components.isEmpty else { return }

        let position = String(components[0])
        let ranks = position.split(separator: "/")

        // Parse board position (FEN goes from rank 8 to rank 1, we go 7 to 0)
        for (index, rank) in ranks.enumerated() {
            let row = 7 - index
            var col = 0

            for char in rank {
                if let emptySquares = Int(String(char)) {
                    // Number means empty squares
                    col += emptySquares
                } else {
                    // Letter means piece
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
            // Correct move!
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
                    // Make opponent's move if exists
                    if self.currentMoveIndex < self.puzzle.solution.count {
                        self.makeOpponentMove()
                    }
                }
            }
        } else {
            // Wrong move
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
            Color(red: 0.2, green: 0.2, blue: 0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Text("Back")
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text(viewModel.puzzle.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(viewModel.puzzle.sideToMove.rawValue.capitalized + " to move")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Button(action: {
                        viewModel.resetPuzzle()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                // Puzzle Info
                HStack {
                    Label(viewModel.puzzle.theme.rawValue, systemImage: viewModel.puzzle.theme.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(8)

                    Text(viewModel.puzzle.difficulty.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(difficultyColor(viewModel.puzzle.difficulty))
                        .cornerRadius(8)

                    Spacer()

                    Text("Move \(viewModel.currentMoveIndex + 1)/\(viewModel.puzzle.solution.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal)

                // Description
                Text(viewModel.puzzle.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Chess Board
                PuzzleBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()

                // Controls
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.showHint()
                    }) {
                        VStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                            Text("Hint")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.resetPuzzle()
                    }) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                            Text("Reset")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }

            // Success overlay
            if viewModel.showSuccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("Correct!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .transition(.scale)
            }

            // Error overlay
            if viewModel.showError {
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Try Again")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .transition(.scale)
            }

            // Completion overlay
            if viewModel.puzzleCompleted {
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)

                    Text("Puzzle Solved!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Attempts: \(viewModel.attempts)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))

                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.resetPuzzle()
                        }) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: onDismiss) {
                            Text("Back to Menu")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(40)
                .background(Color.black.opacity(0.95))
                .cornerRadius(20)
                .transition(.scale)
            }
        }
        .animation(.easeInOut, value: viewModel.showSuccess)
        .animation(.easeInOut, value: viewModel.showError)
        .animation(.easeInOut, value: viewModel.puzzleCompleted)
    }

    func difficultyColor(_ difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
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
        return isLightSquare ? Color(red: 0.93, green: 0.85, blue: 0.72) : Color(red: 0.71, green: 0.53, blue: 0.39)
    }

    private var overlayColor: Color? {
        if isSelected {
            return Color.blue.opacity(0.4)
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
                ChessPieceView(piece: piece, size: squareSize)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .onTapGesture {
            onTap()
        }
    }
}
