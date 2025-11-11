//
//  ContentView.swift
//  ChessGame
//
//  Main view of the chess game application
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChessGameViewModel()
    @State private var showMenu = false

    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.2, blue: 0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                headerView

                // Chess Board
                ChessBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()

                // Game Controls
                controlsView

                // Status Bar
                statusView
            }
            .padding()

            // AI Thinking Overlay
            if viewModel.gameState.isAIThinking {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("AI is thinking...")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top)
                }
            }
        }
        .alert(viewModel.gameOverMessage, isPresented: $viewModel.showGameOverAlert) {
            Button("New Game") {
                viewModel.restartGame()
            }
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $showMenu) {
            GameMenuView(viewModel: viewModel, showMenu: $showMenu)
        }
        .onAppear {
            viewModel.startNewGame()
        }
    }

    private var headerView: some View {
        HStack {
            Text("Chess Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                showMenu = true
            }) {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
    }

    private var controlsView: some View {
        HStack(spacing: 20) {
            Button(action: {
                viewModel.undoMove()
            }) {
                VStack {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title2)
                    Text("Undo")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canUndo() ? Color.orange : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!viewModel.canUndo())

            Button(action: {
                viewModel.restartGame()
            }) {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                    Text("Restart")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Button(action: {
                viewModel.toggleAssistedPlay()
            }) {
                VStack {
                    Image(systemName: viewModel.gameState.assistedPlayEnabled ? "eye.fill" : "eye.slash")
                        .font(.title2)
                    Text("Assist")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.gameState.assistedPlayEnabled ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    private var statusView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Current Turn:")
                    .foregroundColor(.white)
                Text(viewModel.board.currentTurn.rawValue.capitalized)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.board.currentTurn == .white ? .white : .black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.board.currentTurn == .white ? Color.gray.opacity(0.8) : Color.white.opacity(0.9))
                    .cornerRadius(8)
            }

            if viewModel.board.isInCheck(color: viewModel.board.currentTurn) {
                Text("Check!")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .font(.headline)
            }

            HStack {
                Text("Mode:")
                    .foregroundColor(.white)
                Text(viewModel.gameState.gameMode.rawValue)
                    .foregroundColor(.white.opacity(0.8))

                if viewModel.gameState.gameMode == .playerVsAI {
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    Text(viewModel.gameState.aiDifficulty.rawValue)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
