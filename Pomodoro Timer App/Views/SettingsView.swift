//
//  SettingsView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var colorMode: AppColorMode
    @State private var isTimerRunningWhenSettingsOpened = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .fontDesign(.monospaced)) {
                    
                    Picker("Focus Session", selection: Binding(
                        get: { self.timerManager.timer.originalMinutes },
                        set: { userSelection in
                            self.timerManager.timer.originalMinutes = userSelection
                            self.timerManager.timer.minutes = userSelection
                            self.timerManager.timer.seconds = 0
                        }
                    )) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }

                    Picker("Short Break", selection: Binding(
                        get: { self.timerManager.timer.originalBreakMinutes },
                        set: { userSelection in
                            self.timerManager.timer.originalBreakMinutes = userSelection
                            self.timerManager.timer.breakMinutes = userSelection
                            self.timerManager.timer.breakSeconds = 0
                        }
                    )) {
                        ForEach(1...20, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    
                    Picker("Long Break", selection: Binding(
                        get: { self.timerManager.timer.originalLongBreakMinutes },
                        set: { userSelection in
                            self.timerManager.timer.originalLongBreakMinutes = userSelection
                            self.timerManager.timer.longBreakMinutes = userSelection
                            self.timerManager.timer.longBreakSeconds = 0
                        }
                    )) {
                        ForEach(1...45, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }

                Section(header: Text("Appearance")
                    .fontDesign(.monospaced)) {
                    Button(action: toggleColorMode) {
                        HStack {
                            Text("Color Mode")
                            Spacer()
                            Image(systemName: colorMode == .light ? "moon.stars" : "sun.max")
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .modifier(ColorModeViewModifier(mode: colorMode))
        .onAppear { // Stop timer while settings are opened. Resume timer when user leaves settings if timer was previously running.
            if timerManager.isTimerRunning {
                isTimerRunningWhenSettingsOpened = true
                timerManager.stopTimer()
            }
        }
        .onDisappear {
            if isTimerRunningWhenSettingsOpened {
                timerManager.startTimer()
            }
        }
    }
    
    private func toggleColorMode() {
        colorMode = (colorMode == .light) ? .dark : .light
    }
}
