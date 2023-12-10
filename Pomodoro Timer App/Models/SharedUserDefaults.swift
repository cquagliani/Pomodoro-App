//
//  SharedUserDefaults.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/10/23.
//

import Foundation

class SharedUserDefaults {
    static let shared = SharedUserDefaults()
    let userDefaults: UserDefaults
    
    init?() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.pomodoro-timer") else {
            return nil
        }
        self.userDefaults = userDefaults
    }

    func saveSettings(minutes: Int, breakMinutes: Int, longBreakMinutes: Int, focusEmoji: String, breakEmoji: String, colorMode: AppColorMode) {
        userDefaults.set(minutes, forKey: "focusSessionMinutes")
        userDefaults.set(breakMinutes, forKey: "shortBreakMinutes")
        userDefaults.set(longBreakMinutes, forKey: "longBreakMinutes")
        userDefaults.set(focusEmoji, forKey: "focusEmoji")
        userDefaults.set(breakEmoji, forKey: "breakEmoji")
        userDefaults.set(colorMode.rawValue, forKey: "colorMode")
    }

    func getSettings() -> (minutes: Int, breakMinutes: Int, longBreakMinutes: Int, focusEmoji: String, breakEmoji: String, colorMode: AppColorMode) {
        let minutes = userDefaults.integer(forKey: "focusSessionMinutes")
        let breakMinutes = userDefaults.integer(forKey: "shortBreakMinutes")
        let longBreakMinutes = userDefaults.integer(forKey: "longBreakMinutes")
        let focusEmoji = userDefaults.string(forKey: "focusEmoji") ?? "📚"
        let breakEmoji = userDefaults.string(forKey: "breakEmoji") ?? "☕️"
        let colorModeRawValue = userDefaults.string(forKey: "colorMode") ?? AppColorMode.system.rawValue
        let colorMode = AppColorMode(rawValue: colorModeRawValue) ?? .system
        return (minutes, breakMinutes, longBreakMinutes, focusEmoji, breakEmoji, colorMode)
    }
}
