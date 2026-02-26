//
//  SavedGamesManager.swift
//  ChessGame
//
//  Manages persistence of completed and in-progress game records
//

import Foundation
import Combine

class SavedGamesManager: ObservableObject {
    @Published var savedGames: [GameRecord] = []

    private let completedKey = "savedGames"
    private let inProgressKey = "inProgressGame"

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

    // MARK: - In-Progress Game

    func saveInProgressGame(_ record: GameRecord) {
        if let data = try? JSONEncoder().encode(record) {
            UserDefaults.standard.set(data, forKey: inProgressKey)
        }
    }

    func loadInProgressGame() -> GameRecord? {
        guard let data = UserDefaults.standard.data(forKey: inProgressKey),
              let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
            return nil
        }
        return record
    }

    func clearInProgressGame() {
        UserDefaults.standard.removeObject(forKey: inProgressKey)
    }

    // MARK: - Persistence

    private func loadGames() {
        if let data = UserDefaults.standard.data(forKey: completedKey),
           let games = try? JSONDecoder().decode([GameRecord].self, from: data) {
            savedGames = games
        }
    }

    private func persistGames() {
        if let data = try? JSONEncoder().encode(savedGames) {
            UserDefaults.standard.set(data, forKey: completedKey)
        }
    }
}
