//
//  PuzzleMenuView.swift
//  ChessGame
//
//  Puzzle selection menu
//

import SwiftUI

struct PuzzleMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDifficulty: PuzzleDifficulty?
    @State private var selectedPuzzle: ChessPuzzle?
    @State private var showPuzzle = false

    var filteredPuzzles: [ChessPuzzle] {
        if let difficulty = selectedDifficulty {
            return PuzzleData.samplePuzzles.filter { $0.difficulty == difficulty }
        }
        return PuzzleData.samplePuzzles
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(spacing: Spacing.sm) {
                            Text("♟")
                                .font(.system(size: 56))
                                .foregroundColor(AppColors.textPrimary)

                            Text("Chess Puzzles")
                                .font(AppFonts.display())
                                .foregroundColor(AppColors.textPrimary)

                            Text("Train your tactical skills")
                                .font(AppFonts.body())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, Spacing.lg)

                        // Difficulty Filter
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Filter by Difficulty")
                                .font(AppFonts.headline())
                                .foregroundColor(AppColors.textPrimary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.md) {
                                    DifficultyFilterButton(
                                        title: "All",
                                        isSelected: selectedDifficulty == nil
                                    ) {
                                        selectedDifficulty = nil
                                    }

                                    ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
                                        DifficultyFilterButton(
                                            title: difficulty.rawValue,
                                            isSelected: selectedDifficulty == difficulty
                                        ) {
                                            selectedDifficulty = difficulty
                                        }
                                    }
                                }
                                .padding(.horizontal, Spacing.lg)
                            }
                        }

                        // Puzzles List
                        VStack(spacing: Spacing.md) {
                            ForEach(filteredPuzzles) { puzzle in
                                PuzzleCard(puzzle: puzzle) {
                                    selectedPuzzle = puzzle
                                    showPuzzle = true
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                    .padding(.bottom, Spacing.lg)
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showPuzzle) {
                if let puzzle = selectedPuzzle {
                    PuzzleGameView(puzzle: puzzle, onDismiss: {
                        showPuzzle = false
                    })
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DifficultyFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption())
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? AppColors.accent : AppColors.surface)
                .cornerRadius(Radii.xl)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PuzzleCard: View {
    let puzzle: ChessPuzzle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    // Theme icon
                    Image(systemName: puzzle.theme.icon)
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.accent)
                        .frame(width: 40, height: 40)
                        .background(AppColors.accent.opacity(0.15))
                        .cornerRadius(Radii.md)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(puzzle.title)
                            .font(AppFonts.headline())
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: Spacing.sm) {
                            // Theme badge
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: puzzle.theme.icon)
                                    .font(.system(size: 10))
                                Text(puzzle.theme.rawValue)
                                    .font(AppFonts.caption(12))
                            }
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(AppColors.accent.opacity(0.2))
                            .cornerRadius(Radii.sm)

                            // Difficulty badge
                            Text(puzzle.difficulty.rawValue)
                                .font(AppFonts.caption(12))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(difficultyColor(puzzle.difficulty))
                                .cornerRadius(Radii.sm)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                }

                Text(puzzle.description)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)

                HStack {
                    Label("\(puzzle.solution.count) moves", systemImage: "arrow.right")
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.textTertiary)

                    Spacer()

                    Text(puzzle.sideToMove.rawValue.capitalized + " to move")
                        .font(AppFonts.caption(12))
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(Spacing.lg)
            .background(AppColors.surface)
            .cornerRadius(Radii.lg)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    func difficultyColor(_ difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .beginner: return AppColors.success
        case .intermediate: return AppColors.info
        case .advanced: return AppColors.warning
        case .expert: return AppColors.error
        }
    }
}
