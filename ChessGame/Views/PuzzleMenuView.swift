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
                Color(red: 0.2, green: 0.2, blue: 0.25)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Text("♟")
                                .font(.system(size: 60))
                                .foregroundColor(.white)

                            Text("Chess Puzzles")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Train your tactical skills")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)

                        // Difficulty Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Filter by Difficulty")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
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
                                .padding(.horizontal)
                            }
                        }

                        // Puzzles List
                        VStack(spacing: 12) {
                            ForEach(filteredPuzzles) { puzzle in
                                PuzzleCard(puzzle: puzzle) {
                                    selectedPuzzle = puzzle
                                    showPuzzle = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
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
                    .foregroundColor(.white)
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct PuzzleCard: View {
    let puzzle: ChessPuzzle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Theme icon
                    Image(systemName: puzzle.theme.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(puzzle.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            // Theme badge
                            HStack(spacing: 4) {
                                Image(systemName: puzzle.theme.icon)
                                    .font(.system(size: 10))
                                Text(puzzle.theme.rawValue)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(6)

                            // Difficulty badge
                            Text(puzzle.difficulty.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(difficultyColor(puzzle.difficulty))
                                .cornerRadius(6)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }

                Text(puzzle.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                HStack {
                    Label("\(puzzle.solution.count) moves", systemImage: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    Spacer()

                    Text(puzzle.sideToMove.rawValue.capitalized + " to move")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func difficultyColor(_ difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}
