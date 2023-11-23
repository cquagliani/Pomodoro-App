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
    @Binding var showingSettings: Bool
    @State private var isTimerRunningWhenSettingsOpened = false
    @State private var preventDisplaySleep = false

    // Temporary state variables
    @State private var tempFocusSessionMinutes: Int
    @State private var tempShortBreakMinutes: Int
    @State private var tempLongBreakMinutes: Int
    @State private var tempPreventDisplaySleep: Bool
    @State private var tempColorMode: AppColorMode

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._tempFocusSessionMinutes = State(initialValue: timerManager.timer.originalMinutes)
        self._tempShortBreakMinutes = State(initialValue: timerManager.timer.originalBreakMinutes)
        self._tempLongBreakMinutes = State(initialValue: timerManager.timer.originalLongBreakMinutes)
        self._tempPreventDisplaySleep = State(initialValue: UIApplication.shared.isIdleTimerDisabled)
        self._tempColorMode = State(initialValue: colorMode.wrappedValue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .fontDesign(.monospaced)) {
                    
                    Picker("Focus Session", selection: $tempFocusSessionMinutes) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }

                    Picker("Short Break", selection: $tempShortBreakMinutes) {
                        ForEach(1...20, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    
                    Picker("Long Break", selection: $tempLongBreakMinutes) {
                        ForEach(1...45, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }

                Section(header: Text("Appearance")
                    .fontDesign(.monospaced)) {
                    HStack {
                        Text("Toggle Color Mode")
                        Spacer()
                        Button(action: toggleColorMode) {
                            Image(systemName: tempColorMode == .light ? "moon.stars.fill" : "sun.max.fill")
                        }
                        .buttonStyle(DarkLightModeButtonStyle(colorMode: $tempColorMode))
                    }
                }
                
                Section(header: Text("Utilities")
                    .fontDesign(.monospaced)) {
                    Toggle("Prevent Display Going to Sleep", isOn: $tempPreventDisplaySleep)
                }
                
                // Save Button
                Button("Save") {
                    saveSettings()
                }
                .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.greenAccent))
                .padding()
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear {
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
        .modifier(ColorModeViewModifier(mode: tempColorMode))
    }

    private func saveSettings() {
        timerManager.timer.originalMinutes = tempFocusSessionMinutes
        timerManager.timer.originalBreakMinutes = tempShortBreakMinutes
        timerManager.timer.originalLongBreakMinutes = tempLongBreakMinutes
        UIApplication.shared.isIdleTimerDisabled = tempPreventDisplaySleep
        colorMode = tempColorMode
        $showingSettings.wrappedValue = false
    }

    private func toggleColorMode() {
        tempColorMode = (tempColorMode == .light) ? .dark : .light
    }
}
