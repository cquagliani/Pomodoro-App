//
//  MockSettingsView.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/25/23.
//

import SwiftUI

struct MockSettingsView: View {
    @EnvironmentObject var mockTimerManager: MockTimerManager
    @Binding var colorMode: AppColorMode
    @Binding var showingSettings: Bool
    @State private var isTimerRunningWhenSettingsOpened = false
    @State private var preventDisplaySleep = false

    // Temporary state variables to store changed variables before save button is pressed
    @State var tempFocusSessionMinutes: Int
    @State var tempShortBreakMinutes: Int
    @State var tempLongBreakMinutes: Int
    @State var tempPreventDisplaySleep: Bool
    @State var tempColorMode: AppColorMode

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, mockTimerManager: MockTimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._tempFocusSessionMinutes = State(initialValue: mockTimerManager.timer.originalMinutes)
        self._tempShortBreakMinutes = State(initialValue: mockTimerManager.timer.originalBreakMinutes)
        self._tempLongBreakMinutes = State(initialValue: mockTimerManager.timer.originalLongBreakMinutes)
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .padding()
                }

            }
            .onAppear {
                if mockTimerManager.isTimerRunning {
                    isTimerRunningWhenSettingsOpened = true
                    mockTimerManager.stopTimer()
                }
            }
            .onDisappear {
                if isTimerRunningWhenSettingsOpened {
                    mockTimerManager.startTimer()
                }
            }
        }
        .modifier(ColorModeViewModifier(mode: tempColorMode))
    }

    func saveSettings() {
        // Only update original values and reset the timer if changes were made
        if tempFocusSessionMinutes != mockTimerManager.timer.originalMinutes ||
            tempShortBreakMinutes != mockTimerManager.timer.originalBreakMinutes ||
            tempLongBreakMinutes != mockTimerManager.timer.originalLongBreakMinutes
        {
            mockTimerManager.timer.originalMinutes = tempFocusSessionMinutes
            mockTimerManager.timer.originalBreakMinutes = tempShortBreakMinutes
            mockTimerManager.timer.originalLongBreakMinutes = tempLongBreakMinutes
            mockTimerManager.resetTimer()
        }
        
        UIApplication.shared.isIdleTimerDisabled = tempPreventDisplaySleep
        colorMode = tempColorMode
        $showingSettings.wrappedValue = false
    }

    func toggleColorMode() {
        tempColorMode = (tempColorMode == .light) ? .dark : .light
    }
}

