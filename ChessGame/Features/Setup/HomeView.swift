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
                        AppColors.backgroundPrimary,
                        AppColors.backgroundSecondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: Spacing.xxl) {
                    // App Title
                    VStack(spacing: Spacing.md) {
                        Text("♚")
                            .font(.system(size: 72))
                            .foregroundColor(AppColors.textPrimary)
                            .shadow(color: AppColors.accent.opacity(0.3), radius: 10)

                        Text("Chess Master")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Train  ·  Play  ·  Analyze")
                            .font(AppFonts.body())
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)

                    Spacer()

                    // Menu Options
                    VStack(spacing: Spacing.lg) {
                        MenuButton(
                            icon: "gamecontroller.fill",
                            title: "Play Game",
                            subtitle: "Play vs Player or AI",
                            color: AppColors.success
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
                            color: AppColors.info
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
                    .padding(.horizontal, Spacing.xl)

                    Spacer()

                    // Footer
                    Text("Version 1.0")
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.bottom, Spacing.lg)
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
            HStack(spacing: Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 52, height: 52)
                    .background(color)
                    .cornerRadius(Radii.md)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(AppFonts.headline(18))
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(Spacing.lg)
            .background(AppColors.surface)
            .cornerRadius(Radii.lg)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
