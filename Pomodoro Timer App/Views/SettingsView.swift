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
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    @State private var isTimerRunningWhenSettingsOpened = false
    @State private var preventDisplaySleep = false
    @State var showingFocusEmojiGrid = false
    @State var showingBreakEmojiGrid = false

    // Temporary state variables to store changed variables before save button is pressed
    @State var tempFocusSessionMinutes: Int
    @State var tempShortBreakMinutes: Int
    @State var tempLongBreakMinutes: Int
    @State var tempPreventDisplaySleep: Bool
    @State var tempAllowNotifications: Bool
    @State var tempColorMode: AppColorMode

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._focusEmoji = focusEmoji
        self._breakEmoji = breakEmoji
        self._tempFocusSessionMinutes = State(initialValue: timerManager.timer.originalMinutes)
        self._tempShortBreakMinutes = State(initialValue: timerManager.timer.originalBreakMinutes)
        self._tempLongBreakMinutes = State(initialValue: timerManager.timer.originalLongBreakMinutes)
        self._tempPreventDisplaySleep = State(initialValue: UIApplication.shared.isIdleTimerDisabled)
        self._tempColorMode = State(initialValue: colorMode.wrappedValue)
        self._tempAllowNotifications = State(initialValue: false)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pomodoro Timer")
                    .font(.timerSubtitle)) {
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
                    .font(.timerSubtitle)) 
                {
        
                    HStack {
                        Text("Toggle Color Mode")
                        Spacer()
                        Button(action: toggleColorMode) {
                            Image(systemName: tempColorMode == .light ? "moon.stars.fill" : "sun.max.fill")
                        }
                        .buttonStyle(DarkLightModeButtonStyle(colorMode: $tempColorMode))
                    }
                        
                    Button(action: { showingFocusEmojiGrid.toggle() }) {
                        HStack {
                            Text("Focus Emoji")
                            Spacer()
                            Text(focusEmoji)
                        }
                    }
                    .sheet(isPresented: $showingFocusEmojiGrid) {
                        EmojiGridView(emojis: ["📚", "⚡️", "🚀", "🏎️", "🧠", "✍️", "🧐", "🌞"], selection: $focusEmoji, showingFocusEmojiGrid: $showingFocusEmojiGrid, showingBreakEmojiGrid: $showingBreakEmojiGrid)
                    }
                        
                    Button(action: { showingBreakEmojiGrid.toggle() }) {
                        HStack {
                            Text("Break Emoji")
                            Spacer()
                            Text(breakEmoji)
                        }
                    }
                    .sheet(isPresented: $showingBreakEmojiGrid) {
                        EmojiGridView(emojis: ["☕️", "🎮", "🍪", "🪩", "🏝️", "🤠", "😎", "🌚"], selection: $breakEmoji, showingFocusEmojiGrid: $showingFocusEmojiGrid, showingBreakEmojiGrid: $showingBreakEmojiGrid)
                    }

                }
                
                Section(header: Text("Utilities")
                    .font(.timerSubtitle)) {
                    Toggle("Allow Notifications", isOn: $tempAllowNotifications)
                    Toggle("Prevent Display Going to Sleep", isOn: $tempPreventDisplaySleep)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .foregroundColor(Color.blue)
                    .padding()
                }
            }
            .onAppear {
                
                checkNotificationPermission()
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

    func saveSettings() {
        // Only update original values and reset the timer if changes were made
        if tempFocusSessionMinutes != timerManager.timer.originalMinutes ||
            tempShortBreakMinutes != timerManager.timer.originalBreakMinutes ||
            tempLongBreakMinutes != timerManager.timer.originalLongBreakMinutes 
        {
            timerManager.timer.originalMinutes = tempFocusSessionMinutes
            timerManager.timer.originalBreakMinutes = tempShortBreakMinutes
            timerManager.timer.originalLongBreakMinutes = tempLongBreakMinutes
            timerManager.resetTimer()
        }
        
        if tempAllowNotifications {
            NotificationManager.shared.requestNotificationPermission()
        }
        
        UIApplication.shared.isIdleTimerDisabled = tempPreventDisplaySleep
        colorMode = tempColorMode
        $showingSettings.wrappedValue = false
    }

    func toggleColorMode() {
        tempColorMode = (tempColorMode == .light) ? .dark : .light
    }
    
    func checkNotificationPermission() {
        NotificationManager.shared.checkNotificationAuthorization { authorized in
            self.tempAllowNotifications = authorized
        }
    }
}

struct EmojiGridView: View {
    let emojis: [String]
    @Binding var selection: String
    @Binding var showingFocusEmojiGrid: Bool
    @Binding var showingBreakEmojiGrid: Bool
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
        let roundType = showingFocusEmojiGrid == true ? "Focus" : "Break"
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            self.selection = emoji
                        }) {
                            Text(emoji)
                                .font(.title) // Adjust the font size as necessary
                                .frame(width: 30, height: 30) // Adjust the frame size as necessary
                                .padding()
                                .background(self.selection == emoji ? Color.gray.opacity(0.5) : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text("Select \(roundType) Emoji"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFocusEmojiGrid = false
                        showingBreakEmojiGrid = false
                    }
                    .foregroundColor(Color/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding()
                }
            }
        }
    }
}

