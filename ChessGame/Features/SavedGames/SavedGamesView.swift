//
//  SavedGamesView.swift
//  ChessGame
//
//  View for saved and completed games
//

import SwiftUI

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
                                SavedGameCard(game: game,
                                    onCopyPGN: {
                                        let pgn = PGNExporter.export(
                                            moves: game.moves,
                                            result: game.result,
                                            date: game.date
                                        )
                                        UIPasteboard.general.string = pgn
                                    },
                                    onDelete: {
                                        gamesManager.deleteGame(game)
                                    }
                                )
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
    let onCopyPGN: () -> Void
    let onDelete: () -> Void

    @State private var showActions = false

    var body: some View {
        Button(action: { showActions = true }) {
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

                    if let opening = OpeningBook.identify(moves: game.moves) {
                        Text(opening)
                            .font(AppFonts.caption(11))
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(AppColors.surface)
            .cornerRadius(Radii.md)
        }
        .buttonStyle(ScaleButtonStyle())
        .confirmationDialog("Game Actions", isPresented: $showActions) {
            Button("Copy PGN") { onCopyPGN() }
            Button("Delete", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        }
    }

    func resultColor(_ result: GameResult) -> Color {
        switch result {
        case .whiteWins, .blackWins: return AppColors.success
        case .draw, .stalemate: return AppColors.warning
        case .inProgress: return AppColors.info
        }
    }
}
