//
//  SettingsView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var timerManager: TimerManager
    
    @Binding var colorMode: AppColorMode
    @Binding var showingSettings: Bool
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    
    @State private var isTimerRunningWhenSettingsOpened = false
    @State var showingFocusEmojiGrid = false
    @State var showingBreakEmojiGrid = false

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, timerManager: TimerManager) {
        self.viewModel = SettingsViewModel(colorMode: colorMode, showingSettings: showingSettings, focusEmoji: focusEmoji, breakEmoji: breakEmoji, timerManager: timerManager)
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._focusEmoji = focusEmoji
        self._breakEmoji = breakEmoji
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .font(.timerSubtitle)) {
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
                    .font(.timerSubtitle))
                {
        
                    HStack {
                        Text("Toggle Color Mode")
                        Spacer()
                        Button(action: viewModel.toggleColorMode) {
                            Image(systemName: viewModel.tempColorMode == .light ? "moon.stars.fill" : "sun.max.fill")
                        }
                        .buttonStyle(DarkLightModeButtonStyle(colorMode: $viewModel.tempColorMode))
                    }
                        
                    Button(action: { showingFocusEmojiGrid.toggle() }) {
                        HStack {
                            Text("Focus Emoji")
                            Spacer()
                            Text(viewModel.tempFocusEmoji)
                        }
                    }
                    .sheet(isPresented: $showingFocusEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, emojis: ["📚", "⚡️", "🚀", "🏎️", "🧠", "✍️", "🧐", "🌞"], emojiSelection: $viewModel.tempFocusEmoji, showingFocusEmojiGrid: $showingFocusEmojiGrid, showingBreakEmojiGrid: $showingBreakEmojiGrid)
                    }
                        
                    Button(action: { showingBreakEmojiGrid.toggle() }) {
                        HStack {
                            Text("Break Emoji")
                            Spacer()
                            Text(viewModel.tempBreakEmoji)
                        }
                    }
                    .sheet(isPresented: $showingBreakEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, emojis: ["☕️", "🎮", "🍪", "🪩", "🏝️", "🤠", "😎", "🌚"], emojiSelection: $viewModel.tempBreakEmoji, showingFocusEmojiGrid: $showingFocusEmojiGrid, showingBreakEmojiGrid: $showingBreakEmojiGrid)
                    }

                }

                Section(header: Text("Utilities")
                    .font(.timerSubtitle)) {
                    Toggle("Allow Notifications", isOn: $viewModel.tempAllowNotifications)
                    Toggle("Prevent Display Going to Sleep", isOn: $viewModel.tempPreventDisplaySleep)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveSettings()
                    }
                    .foregroundColor(Color.blue)
                    .padding()
                }
            }
            .onAppear {
                viewModel.checkNotificationPermission()
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
        .modifier(ColorModeViewModifier(mode: viewModel.tempColorMode))
    }
}
