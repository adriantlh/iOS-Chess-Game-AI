//
//  OpeningBook.swift
//  ChessGame
//
//  Chess opening name recognition from move sequences
//

import Foundation

struct OpeningBook {
    /// Returns the opening name for a given sequence of moves in algebraic notation
    static func identify(moves: [ChessMove]) -> String? {
        let moveString = moves.prefix(20).map { $0.notation }.joined(separator: " ")

        // Match longest prefix first
        var bestMatch: (name: String, length: Int)?

        for (pattern, name) in openings {
            if moveString.hasPrefix(pattern) {
                if bestMatch == nil || pattern.count > bestMatch!.length {
                    bestMatch = (name, pattern.count)
                }
            }
        }

        return bestMatch?.name
    }

    // Common openings indexed by notation prefix
    private static let openings: [(String, String)] = [
        // Sicilian Defense variations
        ("e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6", "Sicilian Najdorf"),
        ("e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 g6", "Sicilian Dragon"),
        ("e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 e5", "Sicilian Sveshnikov"),
        ("e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3", "Sicilian: Open"),
        ("e4 c5 Nf3 Nc6 d4", "Sicilian: Open"),
        ("e4 c5 Nf3 e6", "Sicilian: French Variation"),
        ("e4 c5 Nc3", "Sicilian: Closed"),
        ("e4 c5 c3", "Sicilian: Alapin"),
        ("e4 c5 Nf3 d6", "Sicilian Defense"),
        ("e4 c5 Nf3", "Sicilian Defense"),
        ("e4 c5", "Sicilian Defense"),

        // French Defense
        ("e4 e6 d4 d5 Nc3 Nf6 Bg5", "French: Classical"),
        ("e4 e6 d4 d5 Nc3 Bb4", "French: Winawer"),
        ("e4 e6 d4 d5 Nd2", "French: Tarrasch"),
        ("e4 e6 d4 d5 e5", "French: Advance"),
        ("e4 e6 d4 d5 exd5", "French: Exchange"),
        ("e4 e6 d4 d5", "French Defense"),
        ("e4 e6", "French Defense"),

        // Caro-Kann
        ("e4 c6 d4 d5 Nc3 dxe4 Nxe4 Bf5", "Caro-Kann: Classical"),
        ("e4 c6 d4 d5 e5", "Caro-Kann: Advance"),
        ("e4 c6 d4 d5 exd5 cxd5", "Caro-Kann: Exchange"),
        ("e4 c6 d4 d5", "Caro-Kann Defense"),
        ("e4 c6", "Caro-Kann Defense"),

        // Italian Game / Giuoco Piano
        ("e4 e5 Nf3 Nc6 Bc4 Bc5 c3", "Giuoco Piano"),
        ("e4 e5 Nf3 Nc6 Bc4 Bc5", "Italian Game"),
        ("e4 e5 Nf3 Nc6 Bc4 Nf6", "Two Knights Defense"),
        ("e4 e5 Nf3 Nc6 Bc4", "Italian Game"),

        // Ruy Lopez
        ("e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7", "Ruy Lopez: Closed"),
        ("e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O", "Ruy Lopez: Morphy"),
        ("e4 e5 Nf3 Nc6 Bb5 a6 Bxc6", "Ruy Lopez: Exchange"),
        ("e4 e5 Nf3 Nc6 Bb5 Nf6", "Ruy Lopez: Berlin"),
        ("e4 e5 Nf3 Nc6 Bb5 a6", "Ruy Lopez: Morphy"),
        ("e4 e5 Nf3 Nc6 Bb5", "Ruy Lopez"),

        // Scotch Game
        ("e4 e5 Nf3 Nc6 d4 exd4 Nxd4", "Scotch Game"),
        ("e4 e5 Nf3 Nc6 d4", "Scotch Game"),

        // King's Gambit
        ("e4 e5 f4 exf4", "King's Gambit Accepted"),
        ("e4 e5 f4 Bc5", "King's Gambit Declined"),
        ("e4 e5 f4", "King's Gambit"),

        // Petrov Defense
        ("e4 e5 Nf3 Nf6", "Petrov Defense"),

        // Philidor Defense
        ("e4 e5 Nf3 d6", "Philidor Defense"),

        // Queen's Gambit
        ("d4 d5 c4 e6 Nc3 Nf6 Bg5", "Queen's Gambit Declined"),
        ("d4 d5 c4 e6 Nc3 Nf6 Nf3", "Queen's Gambit Declined"),
        ("d4 d5 c4 e6 Nc3", "Queen's Gambit Declined"),
        ("d4 d5 c4 dxc4", "Queen's Gambit Accepted"),
        ("d4 d5 c4 c6", "Slav Defense"),
        ("d4 d5 c4 e6", "Queen's Gambit Declined"),
        ("d4 d5 c4", "Queen's Gambit"),

        // Indian Defenses
        ("d4 Nf6 c4 g6 Nc3 Bg7 e4 d6", "King's Indian Defense"),
        ("d4 Nf6 c4 g6 Nc3 Bg7 e4", "King's Indian Defense"),
        ("d4 Nf6 c4 g6 Nc3 Bg7", "King's Indian Defense"),
        ("d4 Nf6 c4 g6 Nc3 d5", "Grunfeld Defense"),
        ("d4 Nf6 c4 e6 Nc3 Bb4", "Nimzo-Indian Defense"),
        ("d4 Nf6 c4 e6 Nf3 b6", "Queen's Indian Defense"),
        ("d4 Nf6 c4 e6 g3", "Catalan Opening"),
        ("d4 Nf6 c4 e6 Nf3 Bb4+", "Bogo-Indian Defense"),
        ("d4 Nf6 c4 e6", "Indian Defense"),
        ("d4 Nf6 c4 c5", "Benoni Defense"),
        ("d4 Nf6 c4", "Indian Defense"),

        // English Opening
        ("c4 e5 Nc3 Nf6", "English: Four Knights"),
        ("c4 e5", "English: Reversed Sicilian"),
        ("c4 Nf6", "English Opening"),
        ("c4 c5", "English: Symmetrical"),
        ("c4", "English Opening"),

        // London System
        ("d4 d5 Bf4", "London System"),
        ("d4 Nf6 Bf4", "London System"),

        // King's Indian Attack
        ("Nf3 d5 g3", "King's Indian Attack"),

        // Broad strokes
        ("e4 e5 Nf3 Nc6", "King's Pawn Game"),
        ("e4 e5 Nf3", "King's Pawn Game"),
        ("e4 e5", "King's Pawn Game"),
        ("e4 d5 exd5 Qxd5", "Scandinavian Defense"),
        ("e4 d5", "Scandinavian Defense"),
        ("e4 g6", "Modern Defense"),
        ("e4 d6", "Pirc Defense"),
        ("e4 Nf6", "Alekhine's Defense"),
        ("e4 b6", "Owen's Defense"),
        ("d4 d5 Nf3", "Queen's Pawn Game"),
        ("d4 d5", "Queen's Pawn Game"),
        ("d4 f5", "Dutch Defense"),
        ("d4", "Queen's Pawn Game"),
        ("e4", "King's Pawn Game"),
        ("Nf3", "Reti Opening"),
    ]
}
