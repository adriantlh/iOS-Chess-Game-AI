//
//  HomeView.swift
//  ChessGame
//
//  Home screen with menu navigation
//

import SwiftUI

enum NavigationDestination {
    case playGame
    case puzzles
    case settings
    case savedGames
}

struct HomeView: View {
    @State private var selectedDestination: NavigationDestination?
    @State private var showGameSetup = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.25, green: 0.25, blue: 0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // App Title
                    VStack(spacing: 10) {
                        Text("♔")
                            .font(.system(size: 80))
                            .foregroundColor(.white)

                        Text("Chess Master")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("Train • Play • Analyze")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)

                    Spacer()

                    // Menu Options
                    VStack(spacing: 20) {
                        MenuButton(
                            icon: "gamecontroller.fill",
                            title: "Play Game",
                            subtitle: "Play vs Player or AI",
                            color: .green
                        ) {
                            selectedDestination = .playGame
                            showGameSetup = true
                        }

                        MenuButton(
                            icon: "puzzlepiece.fill",
                            title: "Chess Puzzles",
                            subtitle: "Train your tactics",
                            color: .purple
                        ) {
                            selectedDestination = .puzzles
                        }

                        MenuButton(
                            icon: "clock.fill",
                            title: "Saved Games",
                            subtitle: "Continue or review games",
                            color: .blue
                        ) {
                            selectedDestination = .savedGames
                        }

                        MenuButton(
                            icon: "gearshape.fill",
                            title: "Settings",
                            subtitle: "Customize your experience",
                            color: .gray
                        ) {
                            selectedDestination = .settings
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // Footer
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showGameSetup) {
                GameSetupView(isPresented: $showGameSetup)
            }
            .fullScreenCover(isPresented: Binding(
                get: { selectedDestination == .puzzles },
                set: { if !$0 { selectedDestination = nil } }
            )) {
                PuzzleMenuView()
            }
            .fullScreenCover(isPresented: Binding(
                get: { selectedDestination == .savedGames },
                set: { if !$0 { selectedDestination = nil } }
            )) {
                SavedGamesView()
            }
            .fullScreenCover(isPresented: Binding(
                get: { selectedDestination == .settings },
                set: { if !$0 { selectedDestination = nil } }
            )) {
                SettingsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .cornerRadius(15)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
