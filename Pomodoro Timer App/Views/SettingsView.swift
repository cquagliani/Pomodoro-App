//
//  SettingsView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @EnvironmentObject var timerManager: TimerManager
    
    @Binding var colorMode: AppColorMode
    @Binding var showingSettings: Bool
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    
    @State private var isTimerRunningWhenSettingsOpened = false
    @State var showingFocusEmojiGrid = false
    @State var showingBreakEmojiGrid = false

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, timerManager: TimerManager) {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(colorMode: colorMode, showingSettings: showingSettings, focusEmoji: focusEmoji, breakEmoji: breakEmoji, timerManager: timerManager))
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
                        Picker("Rounds", selection: $viewModel.tempRounds) {
                        ForEach(1...10, id: \.self) { round in
                            Text("\(round)").tag(round)
                        }
                    }

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

                        Picker("Long Break Every", selection: $viewModel.tempLongBreakInterval) {
                        ForEach(2...10, id: \.self) { interval in
                            Text("\(interval) rounds").tag(interval)
                        }
                    }
                }

                Section(header: Text("Appearance")
                    .font(.timerSubtitle))
                {
                    Picker("Color Mode", selection: $viewModel.tempColorMode) {
                        Text("System").tag(AppColorMode.system)
                        Text("Light").tag(AppColorMode.light)
                        Text("Dark").tag(AppColorMode.dark)
                    }
                        
                    Button(action: { showingFocusEmojiGrid.toggle() }) {
                        HStack {
                            Text("Focus Emoji")
                            Spacer()
                            Text(viewModel.tempFocusEmoji)
                        }
                    }
                    .sheet(isPresented: $showingFocusEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, title: "Select Focus Emoji", emojiSelection: $viewModel.tempFocusEmoji, isPresented: $showingFocusEmojiGrid)
                    }
                        
                    Button(action: { showingBreakEmojiGrid.toggle() }) {
                        HStack {
                            Text("Break Emoji")
                            Spacer()
                            Text(viewModel.tempBreakEmoji)
                        }
                    }
                    .sheet(isPresented: $showingBreakEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, title: "Select Break Emoji", emojiSelection: $viewModel.tempBreakEmoji, isPresented: $showingBreakEmojiGrid)
                    }

                }

                Section(header: Text("Daily Goal")
                    .font(.timerSubtitle)) {
                    HStack {
                        Text("Completed Today")
                        Spacer()
                        Text("\(DailyStatsManager.shared.completedRoundsToday) / \(viewModel.tempDailyGoal)")
                            .foregroundColor(.secondary)
                    }

                    Picker("Daily Focus Goal", selection: $viewModel.tempDailyGoal) {
                        ForEach(1...20, id: \.self) { goal in
                            Text("\(goal) rounds").tag(goal)
                        }
                    }
                }

                Section(header: Text("Auto-Start")
                    .font(.timerSubtitle)) {
                    Toggle("Auto-Start Breaks", isOn: $viewModel.tempAutoStartBreaks)
                    Toggle("Auto-Start Focus Sessions", isOn: $viewModel.tempAutoStartFocus)
                }

                Section(header: Text("Sound & Haptics")
                    .font(.timerSubtitle)) {
                    Picker("Completion Sound", selection: $viewModel.tempCompletionSound) {
                        ForEach(SoundManager.CompletionSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                    .onChange(of: viewModel.tempCompletionSound) { newSound in
                        SoundManager.shared.playCompletionSound(newSound)
                    }
                    Toggle("Haptic Feedback", isOn: $viewModel.tempHapticFeedback)
                }

                Section(header: Text("Utilities")
                    .font(.timerSubtitle)) {
                    Toggle("Allow Notifications", isOn: $viewModel.tempAllowNotifications)
                    Toggle("Prevent Display Going to Sleep", isOn: $viewModel.tempPreventDisplaySleep)
                }

                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Section(header: Text("About")
                    .font(.timerSubtitle),
                    footer: Text("Timer settings and emoji preferences are synced to the home screen widget automatically.")
                        .font(.caption)
                ) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSettings = false
                    }
                    .foregroundColor(.secondary)
                }
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
