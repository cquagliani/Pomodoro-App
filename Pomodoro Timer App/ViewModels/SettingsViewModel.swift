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
    
    @Published var tempFocusEmoji: String
    @Published var tempBreakEmoji: String
    @Published var tempFocusSessionMinutes: Int
    @Published var tempShortBreakMinutes: Int
    @Published var tempLongBreakMinutes: Int
    @Published var tempPreventDisplaySleep: Bool
    @Published var tempAllowNotifications: Bool
    @Published var tempColorMode: AppColorMode

    private var timerManager: TimerManager
    
    // Shared UserDefaults instance
    let sharedUserDefaults: SharedUserDefaults?

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, focusEmoji: Binding<String>, breakEmoji: Binding<String>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self._focusEmoji = focusEmoji
        self._breakEmoji = breakEmoji
        self.timerManager = timerManager
        self.tempFocusEmoji = focusEmoji.wrappedValue
        self.tempBreakEmoji = breakEmoji.wrappedValue
        self.tempFocusSessionMinutes = timerManager.timer.originalMinutes
        self.tempShortBreakMinutes = timerManager.timer.originalBreakMinutes
        self.tempLongBreakMinutes = timerManager.timer.originalLongBreakMinutes
        self.tempPreventDisplaySleep = UIApplication.shared.isIdleTimerDisabled
        self.tempColorMode = colorMode.wrappedValue
        self.tempAllowNotifications = false
        
        // Initialize shared UserDefaults
        self.sharedUserDefaults = SharedUserDefaults()
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
        
        focusEmoji = tempFocusEmoji
        breakEmoji = tempBreakEmoji
        
        sharedUserDefaults?.saveSettings(
            minutes: tempFocusSessionMinutes,
            breakMinutes: tempShortBreakMinutes,
            longBreakMinutes: tempLongBreakMinutes,
            focusEmoji: tempFocusEmoji,
            breakEmoji: tempBreakEmoji,
            colorMode: colorMode
        )
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
