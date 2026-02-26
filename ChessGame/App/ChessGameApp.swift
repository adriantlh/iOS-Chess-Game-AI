//
//  ChessGameApp.swift
//  ChessGame
//
//  Main entry point for the Chess Game application
//

import SwiftUI

@main
struct ChessGameApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            "soundEnabled": true,
            "vibrationEnabled": true,
            "showCoordinates": false,
            "autoPromotionQueen": true
        ])
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
