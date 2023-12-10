//
//  SettingsView+Extensions.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI

extension SettingsView {
    
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
