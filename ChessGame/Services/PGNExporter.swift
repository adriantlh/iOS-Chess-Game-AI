//
//  PGNExporter.swift
//  ChessGame
//
//  Exports chess games in standard PGN (Portable Game Notation) format
//

import Foundation

struct PGNExporter {
    static func export(
        moves: [ChessMove],
        result: GameResult,
        white: String = "Player",
        black: String = "Player",
        event: String = "Chess Master Game",
        site: String = "iOS App",
        date: Date = Date()
    ) -> String {
        var pgn = ""

        // Headers
        pgn += "[Event \"\(event)\"]\n"
        pgn += "[Site \"\(site)\"]\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        pgn += "[Date \"\(formatter.string(from: date))\"]\n"

        pgn += "[White \"\(white)\"]\n"
        pgn += "[Black \"\(black)\"]\n"
        pgn += "[Result \"\(pgnResult(result))\"]\n"

        if let opening = OpeningBook.identify(moves: moves) {
            pgn += "[Opening \"\(opening)\"]\n"
        }

        pgn += "\n"

        // Move text
        var moveText = ""
        for (index, move) in moves.enumerated() {
            if index % 2 == 0 {
                let moveNumber = (index / 2) + 1
                moveText += "\(moveNumber). "
            }
            moveText += move.notation + " "
        }

        moveText += pgnResult(result)
        pgn += moveText.trimmingCharacters(in: .whitespaces) + "\n"

        return pgn
    }

    private static func pgnResult(_ result: GameResult) -> String {
        switch result {
        case .whiteWins: return "1-0"
        case .blackWins: return "0-1"
        case .draw, .stalemate: return "1/2-1/2"
        case .inProgress: return "*"
        }
    }
}
