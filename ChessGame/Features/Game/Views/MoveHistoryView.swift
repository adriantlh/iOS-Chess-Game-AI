//
//  MoveHistoryView.swift
//  ChessGame
//
//  Display move history with algebraic notation
//

import SwiftUI

struct MoveHistoryView: View {
    let moves: [ChessMove]
    let currentMoveIndex: Int?
    let onMoveSelected: ((Int) -> Void)?

    private var pairCount: Int {
        (moves.count + 1) / 2
    }

    var body: some View {
        ScrollViewReader { proxy in
            moveListView
                .onChange(of: moves.count) { _ in
                    scrollToLastMove(proxy: proxy)
                }
        }
    }

    private var moveListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if moves.isEmpty {
                    emptyStateView
                } else {
                    moveRowsView
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .background(AppColors.backgroundPrimary.opacity(0.8))
        .cornerRadius(Radii.md)
    }

    private var emptyStateView: some View {
        Text("No moves yet")
            .foregroundColor(AppColors.textTertiary)
            .padding()
    }

    private var moveRowsView: some View {
        ForEach(0..<pairCount, id: \.self) { pairIndex in
            MovePairRow(
                moveNumber: pairIndex + 1,
                whiteMove: moves[safe: pairIndex * 2],
                blackMove: moves[safe: pairIndex * 2 + 1],
                isWhiteSelected: currentMoveIndex == pairIndex * 2,
                isBlackSelected: currentMoveIndex == pairIndex * 2 + 1,
                onWhiteTap: {
                    onMoveSelected?(pairIndex * 2)
                },
                onBlackTap: {
                    if moves.indices.contains(pairIndex * 2 + 1) {
                        onMoveSelected?(pairIndex * 2 + 1)
                    }
                }
            )
            .id(pairIndex)
        }
    }

    private func scrollToLastMove(proxy: ScrollViewProxy) {
        if !moves.isEmpty {
            let lastPairIndex = (moves.count - 1) / 2
            withAnimation {
                proxy.scrollTo(lastPairIndex, anchor: .bottom)
            }
        }
    }
}

struct MovePairRow: View {
    let moveNumber: Int
    let whiteMove: ChessMove?
    let blackMove: ChessMove?
    let isWhiteSelected: Bool
    let isBlackSelected: Bool
    let onWhiteTap: () -> Void
    let onBlackTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Move number
            Text("\(moveNumber).")
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 40, alignment: .trailing)
                .font(AppFonts.caption())

            // White's move
            if let whiteMove = whiteMove {
                Button(action: onWhiteTap) {
                    Text(whiteMove.notation)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(isWhiteSelected ? AppColors.accent.opacity(0.3) : Color.clear)
                        .font(AppFonts.mono(14))
                }
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }

            // Black's move
            if let blackMove = blackMove {
                Button(action: onBlackTap) {
                    Text(blackMove.notation)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(isBlackSelected ? AppColors.accent.opacity(0.3) : Color.clear)
                        .font(AppFonts.mono(14))
                }
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .background(moveNumber % 2 == 0 ? AppColors.rowAlternate : Color.clear)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
