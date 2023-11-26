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
    var mockTimer: MockDefaultTimer!
    var mockTimerManager: MockTimerManager!
    var viewModel: MockSettingsViewModel!

    override func setUp() {
        super.setUp()
        mockTimer = MockDefaultTimer()
        mockTimerManager = MockTimerManager(timer: mockTimer)

        let colorModeBinding = Binding.constant(AppColorMode.light)
        let showingSettingsBinding = Binding.constant(true)
        viewModel = MockSettingsViewModel(colorMode: colorModeBinding, showingSettings: showingSettingsBinding, mockTimerManager: mockTimerManager)
    }

    func testSaveSettings_WhenTimerValuesChanged_ShouldResetTimer() {
        viewModel.tempFocusSessionMinutes = 30 // Different from default value
        viewModel.saveSettings()
        XCTAssertTrue(mockTimerManager.resetTimerCalled)
    }

    func testSaveSettings_WhenColorModeChanged_ShouldUpdateColorMode() {
        viewModel.tempColorMode = .dark
        viewModel.saveSettings()
        XCTAssertEqual(viewModel.tempColorMode, .dark)
    }
}
