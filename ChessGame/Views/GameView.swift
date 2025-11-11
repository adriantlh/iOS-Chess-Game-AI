//
//  GameView.swift
//  ChessGame
//
//  Main game view with all features integrated
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: ChessGameViewModel
    @StateObject private var timer: ChessTimer?
    @State private var showMoveHistory = false
    @State private var showGameOverAlert = false
    @State private var gameOverMessage = ""

    let gameMode: GameMode
    let aiDifficulty: AIDifficulty
    let playerColor: PieceColor
    let assistedPlayEnabled: Bool
    let timerEnabled: Bool
    let timeControl: TimeControl
    let onDismiss: () -> Void

    init(gameMode: GameMode, aiDifficulty: AIDifficulty, playerColor: PieceColor,
         assistedPlayEnabled: Bool, timerEnabled: Bool, timeControl: TimeControl,
         onDismiss: @escaping () -> Void) {
        self.gameMode = gameMode
        self.aiDifficulty = aiDifficulty
        self.playerColor = playerColor
        self.assistedPlayEnabled = assistedPlayEnabled
        self.timerEnabled = timerEnabled
        self.timeControl = timeControl
        self.onDismiss = onDismiss

        let vm = ChessGameViewModel()
        vm.gameState.gameMode = gameMode
        vm.gameState.aiDifficulty = aiDifficulty
        vm.gameState.playerColor = playerColor
        vm.gameState.assistedPlayEnabled = assistedPlayEnabled
        _viewModel = StateObject(wrappedValue: vm)

        if timerEnabled {
            _timer = StateObject(wrappedValue: ChessTimer(timeControl: timeControl))
        } else {
            _timer = StateObject(wrappedValue: nil)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.2, blue: 0.25)
                .ignoresSafeArea()

            VStack(spacing: 15) {
                // Top Player Timer (opponent/black)
                if timerEnabled, let timer = timer {
                    TimerView(timer: timer, playerColor: .black)
                        .padding(.horizontal)
                }

                // Chess Board
                ChessBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal)

                // Bottom Player Timer (current player/white)
                if timerEnabled, let timer = timer {
                    TimerView(timer: timer, playerColor: .white)
                        .padding(.horizontal)
                }

                // Move History Button
                Button(action: {
                    showMoveHistory.toggle()
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Move History (\(viewModel.board.moveHistory.count))")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                }

                // Game Controls
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.undoMove()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.title3)
                            Text("Undo")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.canUndo() ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!viewModel.canUndo())

                    Button(action: {
                        viewModel.restartGame()
                        timer?.reset()
                        timer?.start()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                            Text("Restart")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.toggleAssistedPlay()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: viewModel.gameState.assistedPlayEnabled ? "eye.fill" : "eye.slash")
                                .font(.title3)
                            Text("Assist")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.gameState.assistedPlayEnabled ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        onDismiss()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.title3)
                            Text("Exit")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Status
                statusView
                    .padding(.horizontal)
            }

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
        .sheet(isPresented: $showMoveHistory) {
            MoveHistorySheet(moves: viewModel.board.moveHistory)
        }
        .alert(gameOverMessage, isPresented: $showGameOverAlert) {
            Button("New Game") {
                viewModel.restartGame()
                timer?.reset()
                timer?.start()
            }
            Button("Exit") {
                onDismiss()
            }
        }
        .onAppear {
            viewModel.startNewGame()
            if timerEnabled {
                timer?.start()
            }
        }
        .onChange(of: viewModel.board.moveHistory.count) { _ in
            // Update timer turn
            timer?.switchTurn(to: viewModel.board.currentTurn)

            // Check game status
            checkGameStatus()
        }
        .onChange(of: timer?.hasTimeExpired) { expired in
            if expired == true, let losingColor = timer?.losingColor {
                gameOverMessage = "\(losingColor.opposite.rawValue.capitalized) wins on time!"
                showGameOverAlert = true
            }
        }
    }

    private var statusView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Turn:")
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
                Text(gameMode.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                if gameMode == .playerVsAI {
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    Text(aiDifficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }

    private func checkGameStatus() {
        let currentColor = viewModel.board.currentTurn

        if viewModel.board.isCheckmate(color: currentColor) {
            gameOverMessage = "\(currentColor.opposite.rawValue.capitalized) wins by checkmate!"
            showGameOverAlert = true
            timer?.pause()
        } else if viewModel.board.isStalemate(color: currentColor) {
            gameOverMessage = "Game ended in stalemate!"
            showGameOverAlert = true
            timer?.pause()
        }
    }
}

struct MoveHistorySheet: View {
    @Environment(\.presentationMode) var presentationMode
    let moves: [ChessMove]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.25)
                    .ignoresSafeArea()

                MoveHistoryView(moves: moves, currentMoveIndex: nil, onMoveSelected: nil)
                    .padding()
            }
            .navigationTitle("Move History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white))
        }
    }
}
