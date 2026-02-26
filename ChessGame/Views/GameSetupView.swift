//
//  GameSetupView.swift
//  ChessGame
//
//  Game setup and configuration before starting a game
//

import SwiftUI

struct GameSetupView: View {
    @Binding var isPresented: Bool
    @State private var selectedMode: GameMode = .playerVsPlayer
    @State private var selectedDifficulty: AIDifficulty = .medium
    @State private var playerColor: PieceColor = .white
    @State private var assistedPlayEnabled: Bool = false
    @State private var enableTimer: Bool = false
    @State private var selectedTimeControl: TimeControl = .blitz5
    @State private var navigateToGame = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        VStack(spacing: Spacing.sm) {
                            Text("New Game")
                                .font(AppFonts.display())
                                .foregroundColor(AppColors.textPrimary)

                            Text("Configure your game settings")
                                .font(AppFonts.body())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, Spacing.lg)

                        // Game Mode
                        SettingSection(title: "Game Mode") {
                            VStack(spacing: Spacing.md) {
                                GameModeCard(
                                    icon: "person.2.fill",
                                    title: "Player vs Player",
                                    description: "Play locally with a friend",
                                    isSelected: selectedMode == .playerVsPlayer
                                ) {
                                    selectedMode = .playerVsPlayer
                                }

                                GameModeCard(
                                    icon: "cpu",
                                    title: "Player vs AI",
                                    description: "Challenge the computer",
                                    isSelected: selectedMode == .playerVsAI
                                ) {
                                    selectedMode = .playerVsAI
                                }
                            }
                        }

                        // AI Settings (only if vs AI)
                        if selectedMode == .playerVsAI {
                            SettingSection(title: "AI Difficulty") {
                                HStack(spacing: Spacing.md) {
                                    ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                        DifficultyButton(
                                            difficulty: difficulty,
                                            isSelected: selectedDifficulty == difficulty
                                        ) {
                                            selectedDifficulty = difficulty
                                        }
                                    }
                                }
                            }

                            SettingSection(title: "Your Color") {
                                HStack(spacing: Spacing.md) {
                                    ColorButton(
                                        color: .white,
                                        isSelected: playerColor == .white
                                    ) {
                                        playerColor = .white
                                    }

                                    ColorButton(
                                        color: .black,
                                        isSelected: playerColor == .black
                                    ) {
                                        playerColor = .black
                                    }
                                }
                            }
                        }

                        // Timer Settings
                        SettingSection(title: "Time Control") {
                            VStack(spacing: Spacing.md) {
                                Toggle(isOn: $enableTimer) {
                                    HStack {
                                        Image(systemName: "timer")
                                            .foregroundColor(AppColors.info)
                                        Text("Enable Timer")
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: AppColors.accent))

                                if enableTimer {
                                    Picker("Time Control", selection: $selectedTimeControl) {
                                        ForEach(TimeControl.allCases, id: \.self) { control in
                                            Text(control.displayName).tag(control)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                        }

                        // Assist Settings
                        SettingSection(title: "Assistance") {
                            Toggle(isOn: $assistedPlayEnabled) {
                                HStack {
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(AppColors.warning)
                                    Text("Show Threatened Pieces")
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.warning))
                        }

                        // Start Button
                        Button(action: {
                            navigateToGame = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .padding(.vertical, Spacing.sm)
                            .background(AppColors.success)
                            .foregroundColor(AppColors.textPrimary)
                            .cornerRadius(Radii.lg)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.top, Spacing.lg)
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $navigateToGame) {
                GameView(
                    gameMode: selectedMode,
                    aiDifficulty: selectedDifficulty,
                    playerColor: playerColor,
                    assistedPlayEnabled: assistedPlayEnabled,
                    timerEnabled: enableTimer,
                    timeControl: selectedTimeControl,
                    onDismiss: {
                        navigateToGame = false
                        isPresented = false
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textSecondary)

            content
                .padding(Spacing.lg)
                .background(AppColors.surface)
                .cornerRadius(Radii.md)
        }
    }
}

struct GameModeCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(AppFonts.body())
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(description)
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textTertiary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                        .font(.system(size: 20))
                }
            }
            .padding(Spacing.lg)
            .background(isSelected ? AppColors.accent.opacity(0.15) : AppColors.backgroundSecondary)
            .cornerRadius(Radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DifficultyButton: View {
    let difficulty: AIDifficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(difficulty.rawValue)
                    .font(AppFonts.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                if isSelected {
                    Circle()
                        .fill(AppColors.success)
                        .frame(width: 8, height: 8)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? AppColors.accent.opacity(0.15) : AppColors.backgroundSecondary)
            .cornerRadius(Radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ColorButton: View {
    let color: PieceColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color == .white ? Color.white : Color.black)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )

                Text(color.rawValue.capitalized)
                    .font(AppFonts.body())
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? AppColors.accent.opacity(0.15) : AppColors.backgroundSecondary)
            .cornerRadius(Radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radii.md)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
