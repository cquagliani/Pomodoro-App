//
//  MockTimerManager.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/23/23.
//

import ActivityKit
import Combine
import XCTest
@testable import Pomodoro_Timer_App

enum MockError: Error {
    case testError
}


class MockTimerManager: ObservableObject {
    var timer: MockDefaultTimer
    var completedRounds = 0
    var completedBreaks = 0
    var isTimerRunning = false
    var hasStartedSession = false
    var hideTimerButtons = false
    var isFocusInterval = true
    var startTimerCallCount = 0
    var stopTimerCallCount = 0
    var resetTimerCallCount = 0
    var resetTimerForNextRoundCalled = false
    var resetTimerForBreakCalled = false
    var resetTimerForLongBreakCalled = false
    var resetTimerCalled = false
    var startTimerCalled = false
    var stopTimerCalled = false
    
    @Published var currentActivity: Activity<TimerAttributes>? = nil
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    var timerSubscription: AnyCancellable?
    
    var startLiveActivityCalled = false
    var startLiveActivityShouldThrowError = false
    var updateLiveActivityCalled = false
    var updateLiveActivityShouldThrowError = false
    var updateLiveActivityCallCount = 0
    var endLiveActivityCalled = false
    var endLiveActivityShouldThrowError = false

    init(timer: MockDefaultTimer) {
        self.timer = timer
    }

    func startTimer() {
        startTimerCalled = true
        startTimerCallCount += 1
        isTimerRunning = true
        hasStartedSession = true
    }

    func stopTimer() {
        stopTimerCalled = true
        stopTimerCallCount += 1
        isTimerRunning = false
    }

    func resetTimer() {
        resetTimerCalled = true
        resetTimerCallCount += 1
        hasStartedSession = false
        isFocusInterval = true
        timer.minutes = timer.originalMinutes
        timer.seconds = timer.originalSeconds
        completedRounds = 0
        completedBreaks = 0
    }

    func tickTimer() {
        if timer.seconds > 0 {
            timer.seconds -= 1
        } else if timer.minutes > 0 {
            timer.minutes -= 1
            timer.seconds = 59
        } else {
            processRoundCompletion()
        }
    }

    func processRoundCompletion() {
        stopTimer()

        if isFocusInterval {
            completedRounds += 1

            if completedRounds < timer.rounds {
                isFocusInterval = false
                resetTimerForBreak()
                startTimer()
            } else {
                resetTimer()
            }
        } else {
            completedBreaks += 1
            isFocusInterval = true

            if completedRounds < timer.rounds {
                resetTimerForNextRound()
                startTimer()
            }
        }
    }

    func resetTimerForNextRound() {
        resetTimerForNextRoundCalled = true
        timer.minutes = timer.originalMinutes
        timer.seconds = timer.originalSeconds
    }

    func resetTimerForBreak() {
        resetTimerForBreakCalled = true
        timer.minutes = timer.originalBreakMinutes
        timer.seconds = timer.originalBreakSeconds
    }
    
    func resetTimerForLongBreak() {
        resetTimerForLongBreakCalled = true
        timer.minutes = timer.longBreakMinutes
        timer.seconds = timer.longBreakSeconds
    }
    
    func startLiveActivity() async throws {
        startLiveActivityCalled = true

        if startLiveActivityShouldThrowError {
            throw MockError.testError
        }
    }
    
    func updateLiveActivity() async throws {
        updateLiveActivityCalled = true
        updateLiveActivityCallCount += 1
        
        if updateLiveActivityShouldThrowError {
            throw MockError.testError
        }
    }
    
    func endLiveActivity() async throws {
        endLiveActivityCalled = true
        
        if endLiveActivityShouldThrowError {
            throw MockError.testError
        }
    }
}
