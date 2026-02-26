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
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                if gamesManager.savedGames.isEmpty {
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "tray")
                            .font(.system(size: 56))
                            .foregroundColor(AppColors.textDisabled)

                        Text("No Saved Games")
                            .font(AppFonts.title())
                            .foregroundColor(AppColors.textSecondary)

                        Text("Your completed games will appear here")
                            .font(AppFonts.body())
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.xl)
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.md) {
                            ForEach(gamesManager.savedGames) { game in
                                SavedGameCard(game: game) {
                                    // Load game action
                                }
                            }
                        }
                        .padding(Spacing.lg)
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
                    .foregroundColor(AppColors.textPrimary)
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
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(game.displayTitle)
                            .font(AppFonts.headline())
                            .foregroundColor(AppColors.textPrimary)

                        Text(game.displayDate)
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Text(game.result.rawValue)
                        .font(AppFonts.caption())
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(resultColor(game.result))
                        .cornerRadius(Radii.sm)
                }

                HStack {
                    Label("\(game.moves.count) moves", systemImage: "arrow.right")
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.textTertiary)

                    if let timeControl = game.timeControl {
                        Label(timeControl.displayName, systemImage: "clock")
                            .font(AppFonts.caption(12))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(AppColors.surface)
            .cornerRadius(Radii.md)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    func resultColor(_ result: GameResult) -> Color {
        switch result {
        case .whiteWins, .blackWins: return AppColors.success
        case .draw, .stalemate: return AppColors.warning
        case .inProgress: return AppColors.info
        }
    }
}
