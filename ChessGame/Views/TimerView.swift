//
//  TimerView.swift
//  ChessGame
//
//  Display chess timer/clock
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timer: ChessTimer
    let playerColor: PieceColor

    var isActive: Bool {
        return (playerColor == .white && timer.isWhiteTurn) ||
               (playerColor == .black && !timer.isWhiteTurn)
    }

    var timeRemaining: TimeInterval {
        return playerColor == .white ? timer.whiteTimeRemaining : timer.blackTimeRemaining
    }

    var isLowTime: Bool {
        return timeRemaining < 30
    }

    var isCriticalTime: Bool {
        return timeRemaining < 10
    }

    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(playerColor == .white ? Color.white : Color.black)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                )

            // Time display
            Text(timer.formattedTime(for: playerColor))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(timeColor)
                .frame(minWidth: 80, alignment: .trailing)

            // Active indicator
            if isActive && timer.isRunning {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .transition(.scale)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut, value: isActive)
    }

    private var timeColor: Color {
        if isCriticalTime {
            return .red
        } else if isLowTime {
            return .orange
        } else {
            return .white
        }
    }

    private var backgroundColor: Color {
        if isActive {
            return Color.blue.opacity(0.2)
        } else {
            return Color.white.opacity(0.1)
        }
    }
}
