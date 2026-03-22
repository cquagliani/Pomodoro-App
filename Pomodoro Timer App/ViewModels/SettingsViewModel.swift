//
//  SettingsViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI
import Foundation

class SettingsViewModel: ObservableObject {
    @Binding var colorMode: AppColorMode
    @Binding var showingSettings: Bool
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    @Binding var longBreakEmoji: String

    @Published var tempFocusEmoji: String
    @Published var tempBreakEmoji: String
    @Published var tempLongBreakEmoji: String
    @Published var tempRounds: Int
    @Published var tempFocusSessionMinutes: Int
    @Published var tempShortBreakMinutes: Int
    @Published var tempLongBreakMinutes: Int
    @Published var tempAutoStartBreaks: Bool
    @Published var tempAutoStartFocus: Bool
    @Published var tempLongBreakInterval: Int
    @Published var tempCompletionSound: SoundManager.CompletionSound
    @Published var tempHapticFeedback: Bool
    @Published var tempDailyGoal: Int
    @Published var tempPreventDisplaySleep: Bool
    @Published var tempAllowNotifications: Bool
    @Published var tempColorMode: AppColorMode

    private var timerManager: TimerManager
    
    // Shared UserDefaults instance
    let sharedUserDefaults: SharedUserDefaults

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, longBreakEmoji: Binding<String>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._focusEmoji = focusEmoji
        self._breakEmoji = breakEmoji
        self._longBreakEmoji = longBreakEmoji
        self.timerManager = timerManager
        self.tempFocusEmoji = focusEmoji.wrappedValue
        self.tempBreakEmoji = breakEmoji.wrappedValue
        self.tempLongBreakEmoji = longBreakEmoji.wrappedValue
        self.tempRounds = timerManager.timer.originalRounds
        self.tempFocusSessionMinutes = timerManager.timer.originalMinutes
        self.tempShortBreakMinutes = timerManager.timer.originalBreakMinutes
        self.tempLongBreakMinutes = timerManager.timer.originalLongBreakMinutes
        self.tempAutoStartBreaks = timerManager.autoStartBreaks
        self.tempAutoStartFocus = timerManager.autoStartFocus
        self.tempLongBreakInterval = timerManager.longBreakInterval
        self.tempCompletionSound = timerManager.completionSound
        self.tempHapticFeedback = timerManager.hapticFeedbackEnabled
        self.tempDailyGoal = DailyStatsManager.shared.dailyGoal
        self.tempPreventDisplaySleep = UIApplication.shared.isIdleTimerDisabled
        self.tempColorMode = colorMode.wrappedValue
        self.tempAllowNotifications = false
        
        // Initialize shared UserDefaults
        self.sharedUserDefaults = SharedUserDefaults()
    }

    func saveSettings() {
        // Only update original values and reset the timer if changes were made
        if tempRounds != timerManager.timer.originalRounds ||
            tempFocusSessionMinutes != timerManager.timer.originalMinutes ||
            tempShortBreakMinutes != timerManager.timer.originalBreakMinutes ||
            tempLongBreakMinutes != timerManager.timer.originalLongBreakMinutes
        {
            timerManager.timer.originalRounds = tempRounds
            timerManager.timer.rounds = tempRounds
            timerManager.timer.originalMinutes = tempFocusSessionMinutes
            timerManager.timer.originalBreakMinutes = tempShortBreakMinutes
            timerManager.timer.originalLongBreakMinutes = tempLongBreakMinutes
            timerManager.resetTimer()
        }
        
        timerManager.autoStartBreaks = tempAutoStartBreaks
        timerManager.autoStartFocus = tempAutoStartFocus
        timerManager.longBreakInterval = tempLongBreakInterval
        timerManager.completionSound = tempCompletionSound
        timerManager.hapticFeedbackEnabled = tempHapticFeedback
        DailyStatsManager.shared.setDailyGoal(tempDailyGoal)

        if tempAllowNotifications {
            NotificationManager.shared.requestNotificationPermission()
        }
        
        UIApplication.shared.isIdleTimerDisabled = tempPreventDisplaySleep
        colorMode = tempColorMode
        $showingSettings.wrappedValue = false
        
        focusEmoji = tempFocusEmoji
        breakEmoji = tempBreakEmoji
        longBreakEmoji = tempLongBreakEmoji

        sharedUserDefaults.saveSettings(
            rounds: tempRounds,
            minutes: tempFocusSessionMinutes,
            breakMinutes: tempShortBreakMinutes,
            longBreakMinutes: tempLongBreakMinutes,
            focusEmoji: tempFocusEmoji,
            breakEmoji: tempBreakEmoji,
            longBreakEmoji: tempLongBreakEmoji,
            colorMode: colorMode
        )
    }

    var hasChanges: Bool {
        tempRounds != timerManager.timer.originalRounds ||
        tempFocusSessionMinutes != timerManager.timer.originalMinutes ||
        tempShortBreakMinutes != timerManager.timer.originalBreakMinutes ||
        tempLongBreakMinutes != timerManager.timer.originalLongBreakMinutes ||
        tempLongBreakInterval != timerManager.longBreakInterval ||
        tempAutoStartBreaks != timerManager.autoStartBreaks ||
        tempAutoStartFocus != timerManager.autoStartFocus ||
        tempCompletionSound != timerManager.completionSound ||
        tempHapticFeedback != timerManager.hapticFeedbackEnabled ||
        tempDailyGoal != DailyStatsManager.shared.dailyGoal ||
        tempPreventDisplaySleep != UIApplication.shared.isIdleTimerDisabled ||
        tempFocusEmoji != focusEmoji ||
        tempBreakEmoji != breakEmoji ||
        tempLongBreakEmoji != longBreakEmoji ||
        tempColorMode != colorMode
    }

    var isDefaults: Bool {
        tempRounds == 4 &&
        tempFocusSessionMinutes == 25 &&
        tempShortBreakMinutes == 5 &&
        tempLongBreakMinutes == 30 &&
        tempLongBreakInterval == 4 &&
        tempAutoStartBreaks == true &&
        tempAutoStartFocus == true &&
        tempCompletionSound == .chime &&
        tempHapticFeedback == true &&
        tempDailyGoal == 8 &&
        tempPreventDisplaySleep == false &&
        tempFocusEmoji == "📚" &&
        tempBreakEmoji == "☕️" &&
        tempLongBreakEmoji == "🏆" &&
        tempColorMode == .system
    }

    func resetToDefaults() {
        tempRounds = 4
        tempFocusSessionMinutes = 25
        tempShortBreakMinutes = 5
        tempLongBreakMinutes = 30
        tempLongBreakInterval = 4
        tempAutoStartBreaks = true
        tempAutoStartFocus = true
        tempCompletionSound = .chime
        tempHapticFeedback = true
        tempDailyGoal = 8
        tempPreventDisplaySleep = false
        tempFocusEmoji = "📚"
        tempBreakEmoji = "☕️"
        tempLongBreakEmoji = "🏆"
        tempColorMode = .system
    }

    func checkNotificationPermission() {
        NotificationManager.shared.checkNotificationAuthorization { authorized in
            self.tempAllowNotifications = authorized
        }
    }
}
