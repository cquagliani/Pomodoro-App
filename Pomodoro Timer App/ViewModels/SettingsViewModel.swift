//
//  SettingsViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Binding var colorMode: AppColorMode
    @Binding var showingSettings: Bool
    
    @Published var tempFocusSessionMinutes: Int
    @Published var tempShortBreakMinutes: Int
    @Published var tempLongBreakMinutes: Int
    @Published var tempPreventDisplaySleep: Bool
    @Published var tempAllowNotifications: Bool
    @Published var tempColorMode: AppColorMode

    private var timerManager: TimerManager

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, timerManager: TimerManager) {
        self._colorMode = colorMode
        self._showingSettings = showingSettings
        self.timerManager = timerManager
        self.tempFocusSessionMinutes = timerManager.timer.originalMinutes
        self.tempShortBreakMinutes = timerManager.timer.originalBreakMinutes
        self.tempLongBreakMinutes = timerManager.timer.originalLongBreakMinutes
        self.tempPreventDisplaySleep = UIApplication.shared.isIdleTimerDisabled
        self.tempColorMode = colorMode.wrappedValue
        self.tempAllowNotifications = false
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

