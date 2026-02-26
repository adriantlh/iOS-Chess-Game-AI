//
//  PuzzleViewModel.swift
//  ChessGame
//
//  ViewModel for puzzle solving logic
//

import Foundation
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
