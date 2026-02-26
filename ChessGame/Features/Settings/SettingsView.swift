//
//  SettingsView.swift
//  ChessGame
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("showCoordinates") private var showCoordinates = false
    @AppStorage("autoPromotionQueen") private var autoPromotionQueen = true
    @AppStorage("boardTheme") private var boardThemeRaw = BoardThemeType.classic.rawValue
    @AppStorage("pieceStyle") private var pieceStyleRaw = PieceStyle.standard.rawValue

    @ObservedObject private var statsManager = StatsManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Game Settings")) {
                        Toggle("Auto-promote to Queen", isOn: $autoPromotionQueen)
                        Toggle("Show Board Coordinates", isOn: $showCoordinates)
                    }

                    Section(header: Text("Board Theme")) {
                        Picker("Board Colors", selection: $boardThemeRaw) {
                            ForEach(BoardThemeType.allCases, id: \.rawValue) { theme in
                                HStack {
                                    Circle().fill(theme.lightSquare).frame(width: 16, height: 16)
                                    Circle().fill(theme.darkSquare).frame(width: 16, height: 16)
                                    Text(theme.rawValue)
                                }
                                .tag(theme.rawValue)
                            }
                        }

                        Picker("Piece Style", selection: $pieceStyleRaw) {
                            ForEach(PieceStyle.allCases, id: \.rawValue) { style in
                                Text(style.rawValue).tag(style.rawValue)
                            }
                        }
                    }

                    Section(header: Text("Audio & Haptics")) {
                        Toggle("Sound Effects", isOn: $soundEnabled)
                        Toggle("Vibration", isOn: $vibrationEnabled)
                    }

                    Section(header: Text("Statistics")) {
                        HStack {
                            Text("Games Played")
                            Spacer()
                            Text("\(statsManager.stats.totalGames)")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Wins / Losses / Draws")
                            Spacer()
                            Text("\(statsManager.stats.wins) / \(statsManager.stats.losses) / \(statsManager.stats.draws)")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Win Rate")
                            Spacer()
                            Text(String(format: "%.1f%%", statsManager.stats.winRate))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Avg. Moves per Game")
                            Spacer()
                            Text(String(format: "%.0f", statsManager.stats.avgMoves))
                                .foregroundColor(.gray)
                        }
                        if statsManager.stats.longestGame > 0 {
                            HStack {
                                Text("Longest Game")
                                Spacer()
                                Text("\(statsManager.stats.longestGame) moves")
                                    .foregroundColor(.gray)
                            }
                        }
                        if statsManager.stats.shortestWin > 0 {
                            HStack {
                                Text("Quickest Win")
                                Spacer()
                                Text("\(statsManager.stats.shortestWin) moves")
                                    .foregroundColor(.gray)
                            }
                        }

                        Button(action: {
                            statsManager.reset()
                        }) {
                            Text("Reset Statistics")
                                .foregroundColor(AppColors.warning)
                        }
                    }

                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("2.0")
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("Chess Master Team")
                                .foregroundColor(.gray)
                        }
                    }

                    Section {
                        Button(action: {
                            soundEnabled = true
                            vibrationEnabled = true
                            showCoordinates = false
                            autoPromotionQueen = true
                            boardThemeRaw = BoardThemeType.classic.rawValue
                            pieceStyleRaw = PieceStyle.standard.rawValue
                        }) {
                            HStack {
                                Spacer()
                                Text("Reset All Settings")
                                    .foregroundColor(AppColors.error)
                                Spacer()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
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
