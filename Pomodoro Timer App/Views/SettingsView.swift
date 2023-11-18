//
//  SettingsView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var rounds: Int
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    var onSave: () -> Void = {} 

    
    var body: some View {
        ZStack {
            Color(red: 237/255, green: 238/255, blue: 240/255, opacity: 1.0).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack(spacing: 25) {
                    settingsCard(emoji: "☕️", label: "Rounds", value: $rounds)
                    settingsCard(emoji: "☕️", label: "Focus", value: $focusMinutes)
                    settingsCard(emoji: "☕️", label: "Break", value: $breakMinutes)
                }
                Spacer()
                HStack {
                    Spacer()
                    saveButton
                        .padding(.horizontal, 25)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    
    private var saveButton: some View {
        Button("Save") {
            onSave()
        }
        .buttonStyle(TimerButtonStyle(backgroundColor: .black, foregroundColor: .green))
    }
}

struct settingsCard: View {
    let emoji: String
    let label: String
    @Binding var value: Int
    
    var body: some View {
        VStack {
            Text(emoji)
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
            TextField("Value", value: $value, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
        }
    }
}
