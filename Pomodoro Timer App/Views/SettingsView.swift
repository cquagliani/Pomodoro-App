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

    // Temporary state variables to store changed variables before save button is pressed
    @State var tempFocusSessionMinutes: Int
    @State var tempShortBreakMinutes: Int
    @State var tempLongBreakMinutes: Int
    @State var tempPreventDisplaySleep: Bool
    @State var tempAllowNotifications: Bool
    @State var tempColorMode: AppColorMode
    @State var focusEmoji: String
    @State var breakEmoji: String

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._tempFocusSessionMinutes = State(initialValue: timerManager.timer.originalMinutes)
        self._tempShortBreakMinutes = State(initialValue: timerManager.timer.originalBreakMinutes)
        self._tempLongBreakMinutes = State(initialValue: timerManager.timer.originalLongBreakMinutes)
        self._tempPreventDisplaySleep = State(initialValue: UIApplication.shared.isIdleTimerDisabled)
        self._tempColorMode = State(initialValue: colorMode.wrappedValue)
        self._tempAllowNotifications = State(initialValue: false)
        self._focusEmoji = State(initialValue: "📚")
        self._breakEmoji = State(initialValue: "☕️")
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
                    .font(.timerSubtitle)) {
                    HStack {
                        Text("Toggle Color Mode")
                        Spacer()
                        Button(action: toggleColorMode) {
                            Image(systemName: tempColorMode == .light ? "moon.stars.fill" : "sun.max.fill")
                        }
                        .buttonStyle(DarkLightModeButtonStyle(colorMode: $tempColorMode))
                    }
                        
                    Picker("Focus Emoji", selection: $focusEmoji) {
                        let allEmojis = generateEmojiArray()
                        ForEach(allEmojis, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                    
                    Picker("Break Emoji", selection: $breakEmoji) {
                        let allEmojis = generateEmojiArray()
                        ForEach(allEmojis, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
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
    
    func generateEmojiArray() -> [String] {
        var emojis = [String]()
        let ranges = [
            0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F700...0x1F77F, // Alchemical Symbols
            0x2600...0x26FF,   // Misc Symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            0x1FA70...0x1FAFF  // Symbols and Pictographs Extended-A
            // Note: This list may not include all emojis and may contain some non-emoji characters.
        ]

        ranges.forEach { range in
            for i in range {
                let c = String(UnicodeScalar(i)!)
                if c.unicodeScalars.first?.properties.isEmoji ?? false {
                    emojis.append(c)
                }
            }
        }

        return emojis
    }


}
