//
//  SavedGamesView.swift
//  ChessGame
//
//  View for saved and completed games
//

import SwiftUI
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

struct SavedGamesView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var gamesManager = SavedGamesManager()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.25)
                    .ignoresSafeArea()

                if gamesManager.savedGames.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))

                        Text("No Saved Games")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Your completed games will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(gamesManager.savedGames) { game in
                                SavedGameCard(game: game) {
                                    // Load game action
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Games")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SavedGameCard: View {
    let game: GameRecord
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.displayTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Text(game.displayDate)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Text(game.result.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(resultColor(game.result))
                        .cornerRadius(8)
                }

                HStack {
                    Label("\(game.moves.count) moves", systemImage: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    if let timeControl = game.timeControl {
                        Label(timeControl.displayName, systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func resultColor(_ result: GameResult) -> Color {
        switch result {
        case .whiteWins, .blackWins: return .green
        case .draw, .stalemate: return .orange
        case .inProgress: return .blue
        }
    }
}
