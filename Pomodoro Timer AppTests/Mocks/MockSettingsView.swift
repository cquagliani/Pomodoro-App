//
//  MockSettingsView.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/25/23.
//

import SwiftUI

struct MockSettingsView: View {
    @ObservedObject var viewModel: MockSettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .fontDesign(.monospaced)) {
                    
                    Picker("Focus Session", selection: $viewModel.tempFocusSessionMinutes) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }

                    Picker("Short Break", selection: $viewModel.tempShortBreakMinutes) {
                        ForEach(1...20, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    
                    Picker("Long Break", selection: $viewModel.tempLongBreakMinutes) {
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
                        Button(action: viewModel.toggleColorMode) {
                            Image(systemName: viewModel.tempColorMode == .light ? "moon.stars.fill" : "sun.max.fill")
                        }
                        .buttonStyle(DarkLightModeButtonStyle(colorMode: $viewModel.tempColorMode))
                    }
                }
                
                Section(header: Text("Utilities")
                    .fontDesign(.monospaced)) {
                    Toggle("Prevent Display Going to Sleep", isOn: $viewModel.tempPreventDisplaySleep)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveSettings()
                    }
                    .padding()
                }

            }
            .onAppear {
                if viewModel.mockTimerManager.isTimerRunning {
                    viewModel.isTimerRunningWhenSettingsOpened = true
                    viewModel.mockTimerManager.stopTimer()
                }
            }
            .onDisappear {
                if viewModel.isTimerRunningWhenSettingsOpened {
                    viewModel.mockTimerManager.startTimer()
                }
            }
        }
        .modifier(ColorModeViewModifier(mode: viewModel.tempColorMode))
    }
}


