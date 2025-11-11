//
//  ChessPuzzle.swift
//  ChessGame
//
//  Chess puzzle model with FEN positions and solutions
//

import Foundation

enum PuzzleDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    var displayColor: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
}

enum PuzzleTheme: String, Codable, CaseIterable {
    case mate = "Checkmate"
    case fork = "Fork"
    case pin = "Pin"
    case skewer = "Skewer"
    case discovery = "Discovered Attack"
    case sacrifice = "Sacrifice"
    case endgame = "Endgame"
    case tactical = "Tactical"

    var icon: String {
        switch self {
        case .mate: return "crown.fill"
        case .fork: return "arrow.triangle.branch"
        case .pin: return "pin.fill"
        case .skewer: return "arrow.right"
        case .discovery: return "eye.fill"
        case .sacrifice: return "flame.fill"
        case .endgame: return "flag.checkered"
        case .tactical: return "brain.head.profile"
        }
    }
}

struct ChessPuzzle: Identifiable, Codable {
    let id: UUID
    let title: String
    let fen: String // FEN notation for the position
    let solution: [PuzzleMove] // Sequence of moves that solve the puzzle
    let difficulty: PuzzleDifficulty
    let theme: PuzzleTheme
    let description: String
    let sideToMove: PieceColor

    init(id: UUID = UUID(), title: String, fen: String, solution: [PuzzleMove],
         difficulty: PuzzleDifficulty, theme: PuzzleTheme, description: String, sideToMove: PieceColor) {
        self.id = id
        self.title = title
        self.fen = fen
        self.solution = solution
        self.difficulty = difficulty
        self.theme = theme
        self.description = description
        self.sideToMove = sideToMove
    }
}

struct PuzzleMove: Codable, Equatable {
    let from: Position
    let to: Position

    init(from: String, to: String) {
        self.from = Position.fromAlgebraic(from)
        self.to = Position.fromAlgebraic(to)
    }

    init(from: Position, to: Position) {
        self.from = from
        self.to = to
    }
}

extension Position {
    static func fromAlgebraic(_ notation: String) -> Position {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let notation = notation.lowercased()

        guard notation.count == 2 else { return Position(row: 0, col: 0) }

        let file = String(notation.prefix(1))
        let rank = String(notation.suffix(1))

        guard let col = files.firstIndex(of: file),
              let row = Int(rank), row >= 1, row <= 8 else {
            return Position(row: 0, col: 0)
        }

        return Position(row: row - 1, col: col)
    }
}

// Sample puzzles data
struct PuzzleData {
    static let samplePuzzles: [ChessPuzzle] = [
        // Beginner Puzzles
        ChessPuzzle(
            title: "Back Rank Mate",
            fen: "6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1",
            solution: [PuzzleMove(from: "e1", to: "e8")],
            difficulty: .beginner,
            theme: .mate,
            description: "Deliver checkmate on the back rank!",
            sideToMove: .white
        ),
        ChessPuzzle(
            title: "Knight Fork",
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1",
            solution: [PuzzleMove(from: "f3", to: "g5"), PuzzleMove(from: "d8", to: "e7"), PuzzleMove(from: "g5", to: "f7")],
            difficulty: .beginner,
            theme: .fork,
            description: "Use your knight to fork the king and rook!",
            sideToMove: .white
        ),
        ChessPuzzle(
            title: "Simple Pin",
            fen: "r1bqkb1r/pppp1ppp/2n5/4p3/2B1n3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1",
            solution: [PuzzleMove(from: "d1", to: "e2")],
            difficulty: .beginner,
            theme: .pin,
            description: "Pin the knight to the king!",
            sideToMove: .white
        ),

        // Intermediate Puzzles
        ChessPuzzle(
            title: "Queen Sacrifice",
            fen: "r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQ1RK1 w - - 0 1",
            solution: [
                PuzzleMove(from: "d1", to: "d5"),
                PuzzleMove(from: "c6", to: "d5"),
                PuzzleMove(from: "c4", to: "d5")
            ],
            difficulty: .intermediate,
            theme: .sacrifice,
            description: "Sacrifice your queen for a winning position!",
            sideToMove: .white
        ),
        ChessPuzzle(
            title: "Skewer Attack",
            fen: "2r2rk1/5ppp/8/3Q4/8/8/5PPP/4R1K1 w - - 0 1",
            solution: [PuzzleMove(from: "d5", to: "a8"), PuzzleMove(from: "c8", to: "a8"), PuzzleMove(from: "e1", to: "e8")],
            difficulty: .intermediate,
            theme: .skewer,
            description: "Use a skewer to win material!",
            sideToMove: .white
        ),

        // Advanced Puzzles
        ChessPuzzle(
            title: "Smothered Mate",
            fen: "6rk/6pp/7N/8/8/8/5PPP/6K1 w - - 0 1",
            solution: [
                PuzzleMove(from: "h6", to: "f7"),
                PuzzleMove(from: "h8", to: "h7"),
                PuzzleMove(from: "f7", to: "g5")
            ],
            difficulty: .advanced,
            theme: .mate,
            description: "Deliver a smothered checkmate!",
            sideToMove: .white
        ),
        ChessPuzzle(
            title: "Discovered Check",
            fen: "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 0 1",
            solution: [PuzzleMove(from: "f3", to: "d4"), PuzzleMove(from: "e8", to: "f8"), PuzzleMove(from: "d4", to: "c6")],
            difficulty: .advanced,
            theme: .discovery,
            description: "Use a discovered check to win material!",
            sideToMove: .white
        ),

        // Expert Puzzles
        ChessPuzzle(
            title: "Complex Combination",
            fen: "r2q1rk1/ppp2ppp/2n1bn2/2bpp3/4P3/2NP1N2/PPPB1PPP/R2Q1RK1 w - - 0 1",
            solution: [
                PuzzleMove(from: "d2", to: "h6"),
                PuzzleMove(from: "g7", to: "h6"),
                PuzzleMove(from: "d1", to: "d5"),
                PuzzleMove(from: "f6", to: "d5"),
                PuzzleMove(from: "c3", to: "d5")
            ],
            difficulty: .expert,
            theme: .tactical,
            description: "Find the brilliant combination!",
            sideToMove: .white
        ),
        ChessPuzzle(
            title: "King and Pawn Endgame",
            fen: "8/8/8/4k3/4P3/4K3/8/8 w - - 0 1",
            solution: [
                PuzzleMove(from: "e3", to: "e2"),
                PuzzleMove(from: "e5", to: "e6"),
                PuzzleMove(from: "e2", to: "e3"),
                PuzzleMove(from: "e6", to: "e5"),
                PuzzleMove(from: "e3", to: "f3")
            ],
            difficulty: .expert,
            theme: .endgame,
            description: "Win the king and pawn endgame with perfect play!",
            sideToMove: .white
        )
    ]
}
