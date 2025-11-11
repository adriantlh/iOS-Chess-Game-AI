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
                Color(red: 0.2, green: 0.2, blue: 0.25)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("New Game")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Configure your game settings")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)

                        // Game Mode
                        SettingSection(title: "Game Mode") {
                            VStack(spacing: 12) {
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
                                HStack(spacing: 12) {
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
                                HStack(spacing: 12) {
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
                            VStack(spacing: 12) {
                                Toggle(isOn: $enableTimer) {
                                    HStack {
                                        Image(systemName: "timer")
                                            .foregroundColor(.blue)
                                        Text("Enable Timer")
                                            .foregroundColor(.white)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))

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
                                        .foregroundColor(.orange)
                                    Text("Show Threatened Pieces")
                                        .foregroundColor(.white)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
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
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
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
                    .foregroundColor(.white)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))

            content
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
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
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyButton: View {
    let difficulty: AIDifficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                if isSelected {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    )

                Text(color.rawValue.capitalized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
