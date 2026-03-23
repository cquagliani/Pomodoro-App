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
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    @Binding var longBreakEmoji: String
    @Binding var selectedTab: Tab

    @State var showingFocusEmojiGrid = false
    @State var showingBreakEmojiGrid = false
    @State var showingLongBreakEmojiGrid = false
    @State private var showingResetConfirmation = false

    init(colorMode: Binding<AppColorMode>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, longBreakEmoji: Binding<String>, timerManager: TimerManager, selectedTab: Binding<Tab>) {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(colorMode: colorMode, focusEmoji: focusEmoji, breakEmoji: breakEmoji, longBreakEmoji: longBreakEmoji, timerManager: timerManager))
        self._colorMode = colorMode
        self._focusEmoji = focusEmoji
        self._breakEmoji = breakEmoji
        self._longBreakEmoji = longBreakEmoji
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .font(.timerSubtitle)) {
                    ExpandableWheelPicker(title: "Rounds", suffix: "", selection: $viewModel.tempRounds, range: 1...10)
                    ExpandableWheelPicker(title: "Focus Session", suffix: "min", selection: $viewModel.tempFocusSessionMinutes, range: 1...60)
                    ExpandableWheelPicker(title: "Short Break", suffix: "min", selection: $viewModel.tempShortBreakMinutes, range: 1...20)
                    ExpandableWheelPicker(title: "Long Break", suffix: "min", selection: $viewModel.tempLongBreakMinutes, range: 1...45)
                    ExpandableWheelPicker(title: "Long Break Every", suffix: "rounds", selection: $viewModel.tempLongBreakInterval, range: 2...10)
                }

                Section(header: Text("Appearance")
                    .font(.timerSubtitle))
                {
                    Picker("Color Mode", selection: $viewModel.tempColorMode) {
                        Text("System").tag(AppColorMode.system)
                        Text("Light").tag(AppColorMode.light)
                        Text("Dark").tag(AppColorMode.dark)
                    }
                    .tint(Color.theme.invertedPrimary)

                    Button(action: { showingFocusEmojiGrid.toggle() }) {
                        HStack {
                            Text("Focus Emoji")
                                .foregroundColor(.primary)
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
                                .foregroundColor(.primary)
                            Spacer()
                            Text(viewModel.tempBreakEmoji)
                        }
                    }
                    .sheet(isPresented: $showingBreakEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, title: "Select Break Emoji", emojiSelection: $viewModel.tempBreakEmoji, isPresented: $showingBreakEmojiGrid)
                    }

                    Button(action: { showingLongBreakEmojiGrid.toggle() }) {
                        HStack {
                            Text("Long Break Emoji")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(viewModel.tempLongBreakEmoji)
                        }
                    }
                    .sheet(isPresented: $showingLongBreakEmojiGrid) {
                        EmojiGridView(colorMode: $viewModel.tempColorMode, title: "Select Long Break Emoji", emojiSelection: $viewModel.tempLongBreakEmoji, isPresented: $showingLongBreakEmojiGrid)
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

                    ExpandableWheelPicker(title: "Daily Focus Goal", suffix: "rounds", selection: $viewModel.tempDailyGoal, range: 1...20)
                }

                Section(header: Text("Auto-Start")
                    .font(.timerSubtitle)) {
                    Toggle("Auto-Start Breaks", isOn: $viewModel.tempAutoStartBreaks)
                        .tint(Color.theme.greenAccent)
                    Toggle("Auto-Start Focus Sessions", isOn: $viewModel.tempAutoStartFocus)
                        .tint(Color.theme.greenAccent)
                }

                Section(header: Text("Sound & Haptics")
                    .font(.timerSubtitle)) {
                    Picker("Completion Sound", selection: $viewModel.tempCompletionSound) {
                        ForEach(SoundManager.CompletionSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                    .tint(Color.theme.invertedPrimary)
                    .onChange(of: viewModel.tempCompletionSound) {
                        SoundManager.shared.playCompletionSound(viewModel.tempCompletionSound)
                    }
                    Toggle("Haptic Feedback", isOn: $viewModel.tempHapticFeedback)
                        .tint(Color.theme.greenAccent)
                }

                Section(header: Text("Utilities")
                    .font(.timerSubtitle)) {
                    Toggle("Allow Notifications", isOn: $viewModel.tempAllowNotifications)
                        .tint(Color.theme.greenAccent)
                    Toggle("Prevent Display Going to Sleep", isOn: $viewModel.tempPreventDisplaySleep)
                        .tint(Color.theme.greenAccent)
                }

                Section {
                    Button("Reset to Defaults") {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(viewModel.isDefaults ? .secondary : .red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(viewModel.isDefaults)
                    .alert("Reset to Defaults", isPresented: $showingResetConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            viewModel.resetToDefaults()
                        }
                    } message: {
                        Text("Are you sure?")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasChanges {
                        Button("Save") {
                            viewModel.saveSettings()
                            selectedTab = .timer
                        }
                        .foregroundColor(Color.blue)
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.checkNotificationPermission()
            }
        }
    }
}

// MARK: - Expandable Wheel Picker

private struct ExpandableWheelPicker: View {
    let title: String
    let suffix: String
    @Binding var selection: Int
    let range: ClosedRange<Int>
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(suffix.isEmpty ? "\(selection)" : "\(selection) \(suffix)")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
            }

            if isExpanded {
                Picker(title, selection: $selection) {
                    ForEach(Array(range), id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .clipped()
            }
        }
    }
}
