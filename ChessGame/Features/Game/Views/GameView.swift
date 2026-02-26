//
//  GameView.swift
//  ChessGame
//
//  Main game view with board, captured pieces, controls, and status
//

import SwiftUI
import UIKit

struct GameView: View {
    @StateObject private var viewModel: ChessGameViewModel
    @State private var showMoveHistory = false
    @State private var showShareSheet = false
    @State private var showAnalysis = false
    @State private var analysisResults: [AnalyzedMove] = []
    @State private var isAnalyzing = false

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
                    timer: timerEnabled ? viewModel.timer : nil
                )
                .padding(.horizontal, Spacing.md)

                // Opening name display
                if let opening = viewModel.openingName {
                    Text(opening)
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.accent)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(AppColors.accent.opacity(0.1))
                        .cornerRadius(Radii.sm)
                        .transition(.opacity)
                }

                // History navigation banner
                if viewModel.isViewingHistory {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 12))
                        Text("Viewing move \((viewModel.viewingMoveIndex ?? 0) + 1) of \(viewModel.board.moveHistory.count)")
                            .font(AppFonts.caption(12))
                        Spacer()
                        Button("Live") {
                            viewModel.goToLivePosition()
                        }
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.success)
                    }
                    .foregroundColor(AppColors.warning)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(Radii.sm)
                    .padding(.horizontal, Spacing.md)
                }

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
                    timer: timerEnabled ? viewModel.timer : nil
                )
                .padding(.horizontal, Spacing.md)

                // Hint display
                if let hintDesc = viewModel.hintDescription {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(AppColors.warning)
                        Text(hintDesc)
                            .font(AppFonts.caption(12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(Radii.sm)
                }

                // Check indicator
                if viewModel.board.isInCheck(color: viewModel.board.currentTurn) && !viewModel.isViewingHistory {
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

                // Move navigation controls
                if !viewModel.board.moveHistory.isEmpty {
                    HStack(spacing: Spacing.md) {
                        Button(action: { viewModel.goToStart() }) {
                            Image(systemName: "backward.end.fill")
                                .font(.system(size: 14))
                        }
                        .disabled(viewModel.viewingMoveIndex == 0)

                        Button(action: { viewModel.goBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14))
                        }
                        .disabled(viewModel.viewingMoveIndex == 0)

                        Button(action: { viewModel.goForward() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .disabled(!viewModel.isViewingHistory)

                        Button(action: { viewModel.goToLivePosition() }) {
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 14))
                        }
                        .disabled(!viewModel.isViewingHistory)
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, Spacing.xs)
                }

                // Game Controls
                HStack(spacing: Spacing.sm) {
                    ControlButton(icon: "arrow.uturn.backward", label: "Undo",
                                  color: viewModel.canUndo() ? AppColors.warning : AppColors.surface) {
                        viewModel.undoMove()
                    }
                    .disabled(!viewModel.canUndo())

                    ControlButton(icon: "lightbulb.fill", label: "Hint",
                                  color: viewModel.hintFrom != nil ? AppColors.warning : AppColors.surface) {
                        if viewModel.hintFrom != nil {
                            viewModel.clearHint()
                        } else {
                            viewModel.requestHint()
                        }
                    }
                    .disabled(viewModel.gameStatus != .inProgress || viewModel.isCalculatingHint)

                    ControlButton(icon: "list.bullet", label: "Moves",
                                  color: AppColors.info.opacity(0.7)) {
                        showMoveHistory.toggle()
                    }

                    Menu {
                        Button(action: {
                            viewModel.restartGame()
                            viewModel.timer?.reset()
                            viewModel.timer?.start()
                        }) {
                            Label("New Game", systemImage: "arrow.clockwise")
                        }

                        if viewModel.gameStatus == .inProgress {
                            Button(action: { viewModel.showConfirmResign = true }) {
                                Label("Resign", systemImage: "flag.fill")
                            }

                            Button(action: { viewModel.offerDraw() }) {
                                Label("Offer Draw", systemImage: "hand.raised")
                            }
                        }

                        Divider()

                        Button(action: {
                            let pgn = viewModel.exportPGN()
                            UIPasteboard.general.string = pgn
                        }) {
                            Label("Copy PGN", systemImage: "doc.on.doc")
                        }

                        Button(action: {
                            showShareSheet = true
                        }) {
                            Label("Share PGN", systemImage: "square.and.arrow.up")
                        }

                        if viewModel.gameStatus != .inProgress {
                            Button(action: {
                                analyzeGame()
                            }) {
                                Label("Analyze Game", systemImage: "wand.and.stars")
                            }
                        }

                        Divider()

                        Button(action: { onDismiss() }) {
                            Label("Exit", systemImage: "xmark")
                        }
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 17, weight: .medium))
                            Text("More")
                                .font(AppFonts.caption(11))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(AppColors.surface)
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(Radii.sm)
                    }

                    ControlButton(
                        icon: viewModel.isAssistedPlayEnabled ? "eye.fill" : "eye.slash",
                        label: "Assist",
                        color: viewModel.isAssistedPlayEnabled ? AppColors.success : AppColors.surface
                    ) {
                        viewModel.toggleAssistedPlay()
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
            if viewModel.isAIThinking {
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

            // Hint calculating indicator
            if viewModel.isCalculatingHint {
                VStack(spacing: Spacing.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.warning))
                    Text("Analyzing...")
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(Spacing.lg)
                .background(AppColors.overlayDark)
                .cornerRadius(Radii.md)
            }

            // Draw offer overlay
            if viewModel.showDrawOffer {
                AppColors.overlayMedium
                    .ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Text("Draw Offered")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textPrimary)

                    Text("Your opponent offers a draw. Accept?")
                        .font(AppFonts.body())
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: Spacing.lg) {
                        Button("Decline") { viewModel.declineDraw() }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .background(AppColors.error)
                            .foregroundColor(AppColors.textPrimary)
                            .cornerRadius(Radii.md)
                            .buttonStyle(ScaleButtonStyle())

                        Button("Accept") { viewModel.acceptDraw() }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .background(AppColors.success)
                            .foregroundColor(AppColors.textPrimary)
                            .cornerRadius(Radii.md)
                            .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(Spacing.xl)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(Radii.xl)
            }

            // Analysis overlay
            if showAnalysis {
                AppColors.overlayMedium
                    .ignoresSafeArea()

                AnalysisOverlay(
                    results: analysisResults,
                    isAnalyzing: isAnalyzing,
                    onDismiss: { showAnalysis = false }
                )
            }
        }
        .animation(AppAnimation.standard, value: viewModel.showPromotionDialog)
        .animation(AppAnimation.quick, value: viewModel.isAIThinking)
        .animation(AppAnimation.quick, value: viewModel.openingName)
        .animation(AppAnimation.quick, value: viewModel.isViewingHistory)
        .sheet(isPresented: $showMoveHistory) {
            MoveHistorySheet(
                moves: viewModel.board.moveHistory,
                currentMoveIndex: viewModel.viewingMoveIndex,
                onMoveSelected: { index in
                    viewModel.goToMove(index: index)
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [viewModel.exportPGN()])
        }
        .alert(viewModel.gameOverMessage, isPresented: $viewModel.showGameOverAlert) {
            Button("New Game") {
                viewModel.restartGame()
                viewModel.timer?.reset()
                viewModel.timer?.start()
            }
            Button("Analyze") {
                analyzeGame()
            }
            Button("Exit") {
                onDismiss()
            }
        }
        .alert("Resign?", isPresented: $viewModel.showConfirmResign) {
            Button("Cancel", role: .cancel) {}
            Button("Resign", role: .destructive) {
                viewModel.resign()
            }
        } message: {
            Text("Are you sure you want to resign this game?")
        }
        .onAppear {
            viewModel.startNewGame()
            if timerEnabled {
                viewModel.setupTimer(timeControl: timeControl)
            }
        }
        .onChange(of: viewModel.board.moveHistory.count) { _ in
            viewModel.timer?.switchTurn(to: viewModel.board.currentTurn)
        }
        .onChange(of: viewModel.gameStatus) { status in
            if status != .inProgress {
                viewModel.timer?.pause()
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
        case .draw, .drawByAgreement:
            result = .draw
        case .resigned(let loser):
            result = loser == .white ? .blackWins : .whiteWins
        case .timeExpired(let loser):
            result = loser == .white ? .blackWins : .whiteWins
        case .inProgress:
            return
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
        StatsManager.shared.recordGame(record: record)
    }

    private func analyzeGame() {
        showAnalysis = true
        isAnalyzing = true

        // Copy move history on main thread before dispatching to background for thread safety
        let movesCopy = viewModel.board.moveHistory

        DispatchQueue.global(qos: .userInitiated).async {
            let analyzer = GameAnalyzer()
            let results = analyzer.analyze(moves: movesCopy)

            DispatchQueue.main.async {
                analysisResults = results
                isAnalyzing = false
            }
        }
    }
}

// MARK: - Analysis Overlay

struct AnalysisOverlay: View {
    let results: [AnalyzedMove]
    let isAnalyzing: Bool
    let onDismiss: () -> Void

    private var blunders: Int { results.filter { $0.quality == .blunder }.count }
    private var mistakes: Int { results.filter { $0.quality == .mistake }.count }
    private var inaccuracies: Int { results.filter { $0.quality == .inaccuracy }.count }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack {
                Text("Game Analysis")
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            if isAnalyzing {
                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Analyzing moves...")
                        .font(AppFonts.body())
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(Spacing.xxl)
            } else {
                // Summary
                HStack(spacing: Spacing.xl) {
                    AnalysisStat(label: "Blunders", count: blunders, color: AppColors.error)
                    AnalysisStat(label: "Mistakes", count: mistakes, color: AppColors.warning)
                    AnalysisStat(label: "Inaccuracies", count: inaccuracies, color: AppColors.info)
                }

                // Move list
                ScrollView {
                    VStack(spacing: Spacing.xs) {
                        ForEach(results.filter { $0.quality == .blunder || $0.quality == .mistake || $0.quality == .inaccuracy }, id: \.moveIndex) { analyzed in
                            HStack(spacing: Spacing.sm) {
                                Text("\(analyzed.moveIndex / 2 + 1)\(analyzed.moveIndex % 2 == 0 ? "." : "...")")
                                    .font(AppFonts.mono(12))
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 36, alignment: .trailing)

                                Text(analyzed.move.notation)
                                    .font(AppFonts.mono(14))
                                    .foregroundColor(AppColors.textPrimary)

                                Text(analyzed.quality.symbol)
                                    .font(AppFonts.mono(14))
                                    .foregroundColor(qualityColor(analyzed.quality))

                                Text(analyzed.quality.rawValue)
                                    .font(AppFonts.caption(11))
                                    .foregroundColor(qualityColor(analyzed.quality))

                                Spacer()

                                Text("\(analyzed.evalChange > 0 ? "+" : "")\(analyzed.evalChange / 100).\(abs(analyzed.evalChange) % 100 / 10)")
                                    .font(AppFonts.mono(12))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(Spacing.xl)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(Radii.xl)
        .padding(Spacing.lg)
    }

    private func qualityColor(_ quality: MoveQuality) -> Color {
        switch quality {
        case .brilliant: return AppColors.accent
        case .best, .good: return AppColors.success
        case .inaccuracy: return AppColors.info
        case .mistake: return AppColors.warning
        case .blunder: return AppColors.error
        }
    }
}

struct AnalysisStat: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(count)")
                .font(AppFonts.title())
                .foregroundColor(color)
            Text(label)
                .font(AppFonts.caption(11))
                .foregroundColor(AppColors.textTertiary)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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

            CapturedPiecesView(pieces: capturedPieces, materialAdvantage: materialAdvantage)

            Spacer()

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
    let currentMoveIndex: Int?
    let onMoveSelected: ((Int) -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                MoveHistoryView(moves: moves, currentMoveIndex: currentMoveIndex, onMoveSelected: onMoveSelected)
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
