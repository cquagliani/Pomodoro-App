//
//  SettingsViewTests.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/23/23.
//

@testable import Pomodoro_Timer_App
import XCTest
import SwiftUI

class SettingsViewTests: XCTestCase {
    let mockTimer = DefaultTimer()
    var mockTimerManager: MockTimerManager!
    var settingsView: SettingsView!

    func testSaveSettings_WhenTimerValuesChanged_ShouldResetTimer() {
        settingsView.tempFocusSessionMinutes = 30 // Different from initial value
        settingsView.tempShortBreakMinutes = 5
        settingsView.tempLongBreakMinutes = 10
        settingsView.saveSettings()
        XCTAssertTrue(mockTimerManager.resetTimerCalled)
    }

    func testSaveSettings_WhenColorModeChanged_ShouldUpdateColorMode() {
        settingsView.tempColorMode = .dark
        settingsView.saveSettings()
        XCTAssertEqual(settingsView.colorMode, .dark)
    }
}
