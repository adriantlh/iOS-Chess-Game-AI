//
//  GameMenuView.swift
//  ChessGame
//
//  Menu for selecting game mode and settings
//

import SwiftUI

struct GameMenuView: View {
    @ObservedObject var viewModel: ChessGameViewModel
    @Binding var showMenu: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Mode")) {
                    Picker("Mode", selection: $viewModel.gameState.gameMode) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if viewModel.gameState.gameMode == .playerVsAI {
                    Section(header: Text("AI Difficulty")) {
                        Picker("Difficulty", selection: $viewModel.gameState.aiDifficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Player Color")) {
                        Picker("Color", selection: $viewModel.gameState.playerColor) {
                            Text("White").tag(PieceColor.white)
                            Text("Black").tag(PieceColor.black)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                Section(header: Text("Assisted Play")) {
                    Toggle("Show Threatened Pieces", isOn: $viewModel.gameState.assistedPlayEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }

                Section {
                    Button(action: {
                        viewModel.startNewGame()
                        showMenu = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Start New Game")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Chess Game Settings")
            .navigationBarItems(trailing: Button("Close") {
                showMenu = false
            })
        }
    }
}
