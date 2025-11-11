//
//  SettingsView.swift
//  ChessGame
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("showCoordinates") private var showCoordinates = false
    @AppStorage("autoPromotionQueen") private var autoPromotionQueen = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.25)
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Game Settings")) {
                        Toggle("Auto-promote to Queen", isOn: $autoPromotionQueen)
                        Toggle("Show Board Coordinates", isOn: $showCoordinates)
                    }

                    Section(header: Text("Audio & Haptics")) {
                        Toggle("Sound Effects", isOn: $soundEnabled)
                        Toggle("Vibration", isOn: $vibrationEnabled)
                    }

                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0")
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("Chess Master Team")
                                .foregroundColor(.gray)
                        }
                    }

                    Section {
                        Button(action: {
                            // Reset all settings
                            soundEnabled = true
                            vibrationEnabled = true
                            showCoordinates = false
                            autoPromotionQueen = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Reset All Settings")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
