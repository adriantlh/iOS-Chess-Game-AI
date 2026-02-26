//
//  GameView.swift
//  ChessGame
//
//  Main game view with board, captured pieces, controls, and status
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: ChessGameViewModel
    @State private var timer: ChessTimer?
    @State private var showMoveHistory = false

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
        _timer = State(initialValue: nil)
    }

    private var topColor: PieceColor {
        playerColor == .white ? .black : .white
    }

    private var bottomColor: PieceColor {
        playerColor
    }

    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.2)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Top player info
                PlayerInfoBar(
                    color: topColor,
                    capturedPieces: topColor == .white ? viewModel.capturedByWhite : viewModel.capturedByBlack,
                    materialAdvantage: topColor == .white ? max(0, viewModel.materialAdvantage) : max(0, -viewModel.materialAdvantage),
                    isCurrentTurn: viewModel.board.currentTurn == topColor,
                    timer: timerEnabled ? timer : nil
                )
                .padding(.horizontal)

                // Chess Board
                ChessBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 8)

                // Bottom player info
                PlayerInfoBar(
                    color: bottomColor,
                    capturedPieces: bottomColor == .white ? viewModel.capturedByWhite : viewModel.capturedByBlack,
                    materialAdvantage: bottomColor == .white ? max(0, viewModel.materialAdvantage) : max(0, -viewModel.materialAdvantage),
                    isCurrentTurn: viewModel.board.currentTurn == bottomColor,
                    timer: timerEnabled ? timer : nil
                )
                .padding(.horizontal)

                // Check indicator
                if viewModel.board.isInCheck(color: viewModel.board.currentTurn) {
                    Text("CHECK")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(6)
                }

                // Game Controls
                HStack(spacing: 10) {
                    ControlButton(icon: "arrow.uturn.backward", label: "Undo",
                                  color: viewModel.canUndo() ? .orange : .gray.opacity(0.5)) {
                        viewModel.undoMove()
                    }
                    .disabled(!viewModel.canUndo())

                    ControlButton(icon: "list.bullet", label: "Moves",
                                  color: .blue.opacity(0.7)) {
                        showMoveHistory.toggle()
                    }

                    ControlButton(icon: "arrow.clockwise", label: "New",
                                  color: .red.opacity(0.8)) {
                        viewModel.restartGame()
                        timer?.reset()
                        timer?.start()
                    }

                    ControlButton(
                        icon: viewModel.gameState.assistedPlayEnabled ? "eye.fill" : "eye.slash",
                        label: "Assist",
                        color: viewModel.gameState.assistedPlayEnabled ? .green : .gray.opacity(0.5)
                    ) {
                        viewModel.toggleAssistedPlay()
                    }

                    ControlButton(icon: "xmark", label: "Exit",
                                  color: .gray.opacity(0.5)) {
                        onDismiss()
                    }
                }
                .padding(.horizontal)

                // Game info
                HStack(spacing: 8) {
                    Text(gameMode.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    if gameMode == .playerVsAI {
                        Text("·")
                            .foregroundColor(.white.opacity(0.3))
                        Text(aiDifficulty.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Text("·")
                        .foregroundColor(.white.opacity(0.3))
                    Text("Move \(viewModel.board.moveHistory.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 4)
            }

            // Promotion Dialog Overlay
            if viewModel.showPromotionDialog {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Promote Pawn")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                            Button(action: {
                                viewModel.completePromotion(pieceType: type)
                            }) {
                                VStack(spacing: 4) {
                                    Text(type.symbol(for: viewModel.board.currentTurn))
                                        .font(.system(size: 40))
                                        .foregroundColor(viewModel.board.currentTurn == .white
                                            ? Color(red: 0.98, green: 0.98, blue: 0.95)
                                            : Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .shadow(color: .black.opacity(0.5), radius: 2)
                                    Text(type.rawValue.capitalized)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .frame(width: 70, height: 70)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color(red: 0.18, green: 0.18, blue: 0.24))
                .cornerRadius(20)
                .shadow(radius: 20)
            }

            // AI Thinking Overlay
            if viewModel.gameState.isAIThinking {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Thinking...")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.showPromotionDialog)
        .animation(.easeInOut(duration: 0.15), value: viewModel.gameState.isAIThinking)
        .sheet(isPresented: $showMoveHistory) {
            MoveHistorySheet(moves: viewModel.board.moveHistory)
        }
        .alert(viewModel.gameOverMessage, isPresented: $viewModel.showGameOverAlert) {
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
                timer = ChessTimer(timeControl: timeControl)
                timer?.start()
            }
        }
        .onChange(of: viewModel.board.moveHistory.count) { _ in
            timer?.switchTurn(to: viewModel.board.currentTurn)
        }
        .onChange(of: viewModel.gameStatus) { status in
            if status != .inProgress {
                timer?.pause()
            }
        }
        .onChange(of: timer?.hasTimeExpired) { expired in
            if expired == true, let losingColor = timer?.losingColor {
                viewModel.gameOverMessage = "\(losingColor.opposite.rawValue.capitalized) wins on time!"
                viewModel.showGameOverAlert = true
            }
        }
        .onChange(of: viewModel.showGameOverAlert) { show in
            if show {
                saveCompletedGame()
            }
        }
    }

    private func saveCompletedGame() {
        let result: GameResult
        switch viewModel.gameStatus {
        case .checkmate(let winner):
            result = winner == .white ? .whiteWins : .blackWins
        case .stalemate:
            result = .stalemate
        case .draw:
            result = .draw
        case .inProgress:
            // Timer win case
            if let losingColor = timer?.losingColor {
                result = losingColor == .white ? .blackWins : .whiteWins
            } else {
                return
            }
        }

        let record = GameRecord(
            gameMode: gameMode,
            playerColor: gameMode == .playerVsAI ? playerColor : nil,
            aiDifficulty: gameMode == .playerVsAI ? aiDifficulty : nil,
            moves: viewModel.board.moveHistory,
            result: result,
            timeControl: timerEnabled ? timeControl : nil
        )

        SavedGamesManager().saveGame(record)
    }
}

// MARK: - Player Info Bar

struct PlayerInfoBar: View {
    let color: PieceColor
    let capturedPieces: [ChessPiece]
    let materialAdvantage: Int
    let isCurrentTurn: Bool
    let timer: ChessTimer?

    var body: some View {
        HStack(spacing: 8) {
            // Turn indicator
            Circle()
                .fill(color == .white ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .opacity(isCurrentTurn ? 1 : 0)
                )

            // Captured pieces
            CapturedPiecesView(pieces: capturedPieces, materialAdvantage: materialAdvantage)

            Spacer()

            // Timer
            if let timer = timer {
                Text(timer.formattedTime(for: color))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor(timer: timer, color: color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isCurrentTurn ? Color.white.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isCurrentTurn ? Color.white.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }

    private func timerColor(timer: ChessTimer, color: PieceColor) -> Color {
        let time = color == .white ? timer.whiteTimeRemaining : timer.blackTimeRemaining
        if time < 10 { return .red }
        if time < 30 { return .orange }
        return .white
    }
}

// MARK: - Captured Pieces View

struct CapturedPiecesView: View {
    let pieces: [ChessPiece]
    let materialAdvantage: Int

    var body: some View {
        HStack(spacing: -2) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                Text(piece.displaySymbol)
                    .font(.system(size: 14))
                    .foregroundColor(piece.color == .white ? .white.opacity(0.8) : .gray)
            }

            if materialAdvantage > 0 {
                Text("+\(materialAdvantage / 100)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Control Button

struct ControlButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

// MARK: - Move History Sheet

struct MoveHistorySheet: View {
    @Environment(\.presentationMode) var presentationMode
    let moves: [ChessMove]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.15, green: 0.15, blue: 0.2)
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
