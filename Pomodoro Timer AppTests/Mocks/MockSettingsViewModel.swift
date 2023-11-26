//
//  MockSettingsViewModel.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/26/23.
//

import SwiftUI

class MockSettingsViewModel: ObservableObject {
    @Published var tempFocusSessionMinutes: Int
    @Published var tempShortBreakMinutes: Int
    @Published var tempLongBreakMinutes: Int
    @Published var tempPreventDisplaySleep: Bool
    @Published var tempColorMode: AppColorMode
    @State var isTimerRunningWhenSettingsOpened = false
    @State var preventDisplaySleep = false

    public var mockTimerManager: MockTimerManager
    private var originalColorMode: AppColorMode
    private var showingSettings: Binding<Bool>

    init(colorMode: Binding<AppColorMode>, showingSettings: Binding<Bool>, mockTimerManager: MockTimerManager) {
        self._tempFocusSessionMinutes = Published(initialValue: mockTimerManager.timer.originalMinutes)
        self._tempShortBreakMinutes = Published(initialValue: mockTimerManager.timer.originalBreakMinutes)
        self._tempLongBreakMinutes = Published(initialValue: mockTimerManager.timer.originalLongBreakMinutes)
        self._tempPreventDisplaySleep = Published(initialValue: UIApplication.shared.isIdleTimerDisabled)
        self._tempColorMode = Published(initialValue: colorMode.wrappedValue)

        self.mockTimerManager = mockTimerManager
        self.originalColorMode = colorMode.wrappedValue
        self.showingSettings = showingSettings
    }

    func saveSettings() {
        if tempFocusSessionMinutes != mockTimerManager.timer.originalMinutes ||
            tempShortBreakMinutes != mockTimerManager.timer.originalBreakMinutes ||
            tempLongBreakMinutes != mockTimerManager.timer.originalLongBreakMinutes
        {
            mockTimerManager.timer.originalMinutes = tempFocusSessionMinutes
            mockTimerManager.timer.originalBreakMinutes = tempShortBreakMinutes
            mockTimerManager.timer.originalLongBreakMinutes = tempLongBreakMinutes
            mockTimerManager.resetTimer()
        }

        UIApplication.shared.isIdleTimerDisabled = tempPreventDisplaySleep
        originalColorMode = tempColorMode
        showingSettings.wrappedValue = false
    }

    func toggleColorMode() {
        tempColorMode = (tempColorMode == .light) ? .dark : .light
    }
}


