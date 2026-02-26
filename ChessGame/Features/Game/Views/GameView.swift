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
            AppColors.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: Spacing.sm) {
                // Top player info
                PlayerInfoBar(
                    color: topColor,
                    label: topColor == playerColor ? "You" : (gameMode == .playerVsAI ? "AI" : "Player 2"),
                    capturedPieces: topColor == .white ? viewModel.capturedByWhite : viewModel.capturedByBlack,
                    materialAdvantage: topColor == .white ? max(0, viewModel.materialAdvantage) : max(0, -viewModel.materialAdvantage),
                    isCurrentTurn: viewModel.board.currentTurn == topColor,
                    timer: timerEnabled ? timer : nil
                )
                .padding(.horizontal, Spacing.md)

                // Chess Board
                ChessBoardView(viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, Spacing.md)

                // Bottom player info
                PlayerInfoBar(
                    color: bottomColor,
                    label: bottomColor == playerColor ? "You" : (gameMode == .playerVsAI ? "AI" : "Player 2"),
                    capturedPieces: bottomColor == .white ? viewModel.capturedByWhite : viewModel.capturedByBlack,
                    materialAdvantage: bottomColor == .white ? max(0, viewModel.materialAdvantage) : max(0, -viewModel.materialAdvantage),
                    isCurrentTurn: viewModel.board.currentTurn == bottomColor,
                    timer: timerEnabled ? timer : nil
                )
                .padding(.horizontal, Spacing.md)

                // Check indicator
                if viewModel.board.isInCheck(color: viewModel.board.currentTurn) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("CHECK")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(AppColors.error)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.error.opacity(0.15))
                    .cornerRadius(Radii.sm)
                }

                // Game Controls
                HStack(spacing: Spacing.sm) {
                    ControlButton(icon: "arrow.uturn.backward", label: "Undo",
                                  color: viewModel.canUndo() ? AppColors.warning : AppColors.surface) {
                        viewModel.undoMove()
                    }
                    .disabled(!viewModel.canUndo())

                    ControlButton(icon: "list.bullet", label: "Moves",
                                  color: AppColors.info.opacity(0.7)) {
                        showMoveHistory.toggle()
                    }

                    ControlButton(icon: "arrow.clockwise", label: "New",
                                  color: AppColors.error.opacity(0.8)) {
                        viewModel.restartGame()
                        timer?.reset()
                        timer?.start()
                    }

                    ControlButton(
                        icon: viewModel.gameState.assistedPlayEnabled ? "eye.fill" : "eye.slash",
                        label: "Assist",
                        color: viewModel.gameState.assistedPlayEnabled ? AppColors.success : AppColors.surface
                    ) {
                        viewModel.toggleAssistedPlay()
                    }

                    ControlButton(icon: "xmark", label: "Exit",
                                  color: AppColors.surface) {
                        onDismiss()
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Game info
                HStack(spacing: Spacing.sm) {
                    Text(gameMode.rawValue)
                        .font(AppFonts.caption(13))
                        .foregroundColor(AppColors.textTertiary)

                    if gameMode == .playerVsAI {
                        Text("·")
                            .foregroundColor(AppColors.textDisabled)
                        Text(aiDifficulty.rawValue)
                            .font(AppFonts.caption(13))
                            .foregroundColor(AppColors.textTertiary)
                    }

                    Text("·")
                        .foregroundColor(AppColors.textDisabled)
                    Text("Move \(viewModel.board.moveHistory.count)")
                        .font(AppFonts.caption(13))
                        .foregroundColor(AppColors.textTertiary)
                }
                .padding(.bottom, Spacing.xs)
            }

            // Promotion Dialog Overlay
            if viewModel.showPromotionDialog {
                AppColors.overlayMedium
                    .ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Text("Promote Pawn")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: Spacing.md) {
                        ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                            Button(action: {
                                viewModel.completePromotion(pieceType: type)
                            }) {
                                VStack(spacing: Spacing.xs) {
                                    Text(type.symbol(for: viewModel.board.currentTurn))
                                        .font(.system(size: 42))
                                        .foregroundColor(viewModel.board.currentTurn == .white
                                            ? AppColors.whitePiece : AppColors.blackPiece)
                                        .shadow(color: .black.opacity(0.5), radius: 2)
                                    Text(type.rawValue.capitalized)
                                        .font(AppFonts.caption(12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .frame(width: 76, height: 76)
                                .background(AppColors.surfaceElevated)
                                .cornerRadius(Radii.md)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                .padding(Spacing.xl)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(Radii.xl)
                .shadow(color: AppColors.overlayMedium, radius: 20)
            }

            // AI Thinking Overlay
            if viewModel.gameState.isAIThinking {
                AppColors.overlayLight
                    .ignoresSafeArea()

                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Thinking...")
                        .foregroundColor(AppColors.textSecondary)
                        .font(AppFonts.caption())
                }
                .padding(Spacing.xl)
                .background(AppColors.overlayDark)
                .cornerRadius(Radii.lg)
            }
        }
        .animation(AppAnimation.standard, value: viewModel.showPromotionDialog)
        .animation(AppAnimation.quick, value: viewModel.gameState.isAIThinking)
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
    let label: String
    let capturedPieces: [ChessPiece]
    let materialAdvantage: Int
    let isCurrentTurn: Bool
    let timer: ChessTimer?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Turn indicator + label
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color == .white ? AppColors.whitePiece : AppColors.blackPiece)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle().stroke(AppColors.textDisabled, lineWidth: 1)
                        )

                    if isCurrentTurn {
                        Circle()
                            .stroke(AppColors.success, lineWidth: 2.5)
                            .frame(width: 26, height: 26)
                    }
                }
                .frame(width: 28, height: 28)

                Text(label)
                    .font(AppFonts.caption())
                    .foregroundColor(isCurrentTurn ? AppColors.textPrimary : AppColors.textTertiary)
            }

            // Captured pieces
            CapturedPiecesView(pieces: capturedPieces, materialAdvantage: materialAdvantage)

            Spacer()

            // Timer
            if let timer = timer {
                Text(timer.formattedTime(for: color))
                    .font(AppFonts.mono(18))
                    .foregroundColor(timerColor(timer: timer, color: color))
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(isCurrentTurn ? AppColors.surface : Color.clear)
                    .cornerRadius(Radii.sm)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(isCurrentTurn ? AppColors.surface : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: Radii.sm)
                .stroke(isCurrentTurn ? AppColors.success.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
        .cornerRadius(Radii.sm)
        .animation(AppAnimation.quick, value: isCurrentTurn)
    }

    private func timerColor(timer: ChessTimer, color: PieceColor) -> Color {
        let time = color == .white ? timer.whiteTimeRemaining : timer.blackTimeRemaining
        if time < 10 { return AppColors.error }
        if time < 30 { return AppColors.warning }
        return AppColors.textPrimary
    }
}

// MARK: - Captured Pieces View

struct CapturedPiecesView: View {
    let pieces: [ChessPiece]
    let materialAdvantage: Int

    var body: some View {
        HStack(spacing: -1) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                Text(piece.displaySymbol)
                    .font(.system(size: 15))
                    .foregroundColor(piece.color == .white ? AppColors.textSecondary : .gray)
            }

            if materialAdvantage > 0 {
                Text("+\(materialAdvantage / 100)")
                    .font(AppFonts.caption(12))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.leading, Spacing.xs)
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
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                Text(label)
                    .font(AppFonts.caption(11))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(color)
            .foregroundColor(AppColors.textPrimary)
            .cornerRadius(Radii.sm)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Move History Sheet

struct MoveHistorySheet: View {
    @Environment(\.presentationMode) var presentationMode
    let moves: [ChessMove]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                MoveHistoryView(moves: moves, currentMoveIndex: nil, onMoveSelected: nil)
                    .padding()
            }
            .navigationTitle("Move History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(AppColors.textPrimary))
        }
    }
}
