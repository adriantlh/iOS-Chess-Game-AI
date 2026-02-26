//
//  SavedGamesManager.swift
//  ChessGame
//
//  Manages persistence of completed game records
//

import Foundation
import Combine

class SavedGamesManager: ObservableObject {
    @Published var savedGames: [GameRecord] = []

    init() {
        loadGames()
    }

    func saveGame(_ game: GameRecord) {
        savedGames.insert(game, at: 0)
        persistGames()
    }

    func deleteGame(_ game: GameRecord) {
        savedGames.removeAll { $0.id == game.id }
        persistGames()
    }

    private func loadGames() {
        if let data = UserDefaults.standard.data(forKey: "savedGames"),
           let games = try? JSONDecoder().decode([GameRecord].self, from: data) {
            savedGames = games
        }
    }

    private func persistGames() {
        if let data = try? JSONEncoder().encode(savedGames) {
            UserDefaults.standard.set(data, forKey: "savedGames")
        }
    }
}
