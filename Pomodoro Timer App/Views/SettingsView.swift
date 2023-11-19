//
//  SettingsView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showingSettings: Bool
    @Binding var rounds: Int
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    var onSave: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color(red: 237/255, green: 238/255, blue: 240/255, opacity: 1.0).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                VStack(spacing: 25) {
                    settingsCard(emoji: "🔁", label: "Rounds", value: $rounds)
                    settingsCard(emoji: "📚", label: "Focus", value: $focusMinutes)
                    settingsCard(emoji: "☕️", label: "Break", value: $breakMinutes)
                }
                HStack {
                    Spacer()
                    cancelButton
                    saveButton
                }
                .padding(20)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            showingSettings = false
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: .cyan))
    }
    
    private var saveButton: some View {
        Button("Save") {
            onSave()
            showingSettings = false
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: .green))
    }
}

struct settingsCard: View {
    let emoji: String
    let label: String
    @Binding var value: Int
    
    var body: some View {
        let maxNum: Int = (label == "Rounds") ? 10 : 60
        VStack {
            Text(emoji)
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
            Stepper("\(label): \(value)", value: $value, in: 1...maxNum)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
        }
    }
}
