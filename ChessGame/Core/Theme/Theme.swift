//
//  Theme.swift
//  ChessGame
//
//  Centralized design system: colors, typography, spacing, and animation constants
//

import SwiftUI

// MARK: - Colors

enum AppColors {
    // Background hierarchy
    static let backgroundPrimary = Color(red: 0.11, green: 0.11, blue: 0.15)
    static let backgroundSecondary = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let surface = Color.white.opacity(0.08)
    static let surfaceElevated = Color.white.opacity(0.12)

    // Board
    static let boardLight = Color(red: 0.93, green: 0.85, blue: 0.72)
    static let boardDark = Color(red: 0.71, green: 0.53, blue: 0.39)
    static let boardBorder = Color.black.opacity(0.7)

    // Board overlays
    static let selectedSquare = Color(red: 0.3, green: 0.55, blue: 0.85).opacity(0.55)
    static let lastMoveHighlight = Color(red: 0.85, green: 0.78, blue: 0.1).opacity(0.5)
    static let checkHighlight = Color.red.opacity(0.6)
    static let threatenedSquare = Color.orange.opacity(0.45)
    static let moveIndicator = Color.black.opacity(0.25)
    static let captureIndicator = Color(red: 0.85, green: 0.25, blue: 0.2).opacity(0.6)

    // Piece colors
    static let whitePiece = Color(red: 0.98, green: 0.98, blue: 0.95)
    static let blackPiece = Color(red: 0.12, green: 0.12, blue: 0.12)

    // Text hierarchy
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    static let textDisabled = Color.white.opacity(0.35)

    // Semantic colors
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let warning = Color.orange
    static let error = Color(red: 0.9, green: 0.25, blue: 0.2)
    static let info = Color(red: 0.3, green: 0.55, blue: 0.9)

    // Accent
    static let accent = Color(red: 0.35, green: 0.55, blue: 0.9)

    // Overlays
    static let overlayLight = Color.black.opacity(0.25)
    static let overlayMedium = Color.black.opacity(0.5)
    static let overlayDark = Color.black.opacity(0.8)
    static let overlayOpaque = Color.black.opacity(0.92)

    // Misc
    static let rowAlternate = Color.white.opacity(0.04)
    static let completion = Color.yellow
}

// MARK: - Typography

enum AppFonts {
    static func display(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold)
    }
    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold)
    }
    static func headline(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium)
    }
    static func mono(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}

// MARK: - Spacing (4pt grid)

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radii

enum Radii {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
    static let xl: CGFloat = 20
}

// MARK: - Animation

enum AppAnimation {
    static let quick: Animation = .easeInOut(duration: 0.15)
    static let standard: Animation = .easeInOut(duration: 0.25)
    static let slow: Animation = .easeInOut(duration: 0.35)
    static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.7)
}

// MARK: - Board Constants

enum BoardStyle {
    static let moveIndicatorRatio: CGFloat = 0.33
    static let captureRingRatio: CGFloat = 0.85
    static let captureRingWidth: CGFloat = 3
    static let pieceScale: CGFloat = 0.78
    static let coordinateFontRatio: CGFloat = 0.2
    static let borderWidth: CGFloat = 2.5
    static let cornerRadius: CGFloat = 5
}

// MARK: - Board Themes

enum BoardThemeType: String, CaseIterable, Codable {
    case classic = "Classic"
    case blue = "Blue"
    case green = "Green"
    case purple = "Purple"
    case marble = "Marble"

    var lightSquare: Color {
        switch self {
        case .classic: return Color(red: 0.93, green: 0.85, blue: 0.72)
        case .blue: return Color(red: 0.82, green: 0.87, blue: 0.95)
        case .green: return Color(red: 0.87, green: 0.93, blue: 0.84)
        case .purple: return Color(red: 0.88, green: 0.83, blue: 0.95)
        case .marble: return Color(red: 0.92, green: 0.91, blue: 0.89)
        }
    }

    var darkSquare: Color {
        switch self {
        case .classic: return Color(red: 0.71, green: 0.53, blue: 0.39)
        case .blue: return Color(red: 0.42, green: 0.55, blue: 0.72)
        case .green: return Color(red: 0.45, green: 0.63, blue: 0.42)
        case .purple: return Color(red: 0.55, green: 0.4, blue: 0.68)
        case .marble: return Color(red: 0.55, green: 0.54, blue: 0.52)
        }
    }
}

// MARK: - Piece Style

enum PieceStyle: String, CaseIterable, Codable {
    case standard = "Standard"
    case filled = "Filled"
    case outlined = "Outlined"

    func symbol(type: PieceType, color: PieceColor) -> String {
        switch self {
        case .standard:
            return type.symbol(for: color)
        case .filled:
            switch type {
            case .king: return color == .white ? "♔" : "♚"
            case .queen: return color == .white ? "♕" : "♛"
            case .rook: return color == .white ? "♖" : "♜"
            case .bishop: return color == .white ? "♗" : "♝"
            case .knight: return color == .white ? "♘" : "♞"
            case .pawn: return color == .white ? "♙" : "♟"
            }
        case .outlined:
            switch type {
            case .king: return "♔"
            case .queen: return "♕"
            case .rook: return "♖"
            case .bishop: return "♗"
            case .knight: return "♘"
            case .pawn: return "♙"
            }
        }
    }
}

// MARK: - Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
