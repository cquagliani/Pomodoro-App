//
//  TimerViewModelTests.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/19/23.
//

import XCTest
@testable import Pomodoro_Timer_App

class MockTimerManager: TimerManagerProtocol {
    var timer: DefaultTimer
    var completedRounds = 0
    var completedBreaks = 0
    var isTimerRunning = false
    var hasStartedSession = false
    var isFocusInterval = true
    var startTimerCallCount = 0
    var stopTimerCallCount = 0
    var resetTimerCallCount = 0
    var resetTimerForNextRoundCalled = false
    var resetTimerForBreakCalled = false

    init(timer: DefaultTimer) {
        self.timer = timer
    }

    func startTimer() {
        startTimerCallCount += 1
        isTimerRunning = true
        hasStartedSession = true
    }

    func stopTimer() {
        stopTimerCallCount += 1
        isTimerRunning = false
    }

    func resetTimer() {
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
}



final class TimerViewModelTests: XCTestCase {
    
    func testStartTimer() {
        let mockTimer = DefaultTimer()
        let mockTimerManager = MockTimerManager(timer: mockTimer)
        
        XCTAssertFalse(mockTimerManager.isTimerRunning, "Timer should not be running initially")
        XCTAssertFalse(mockTimerManager.hasStartedSession, "Session should not have started initially")
        XCTAssertEqual(mockTimerManager.startTimerCallCount, 0)

        mockTimerManager.startTimer()

        XCTAssertTrue(mockTimerManager.isTimerRunning, "isTimerRunning should be true after starting")
        XCTAssertTrue(mockTimerManager.hasStartedSession, "hasStartedSession should be true after starting")
        XCTAssertEqual(mockTimerManager.startTimerCallCount, 1)
    }

    func testStopTimer() {
        let mockTimer = DefaultTimer()
        let mockTimerManager = MockTimerManager(timer: mockTimer)
        
        mockTimerManager.startTimer()
        
        XCTAssertTrue(mockTimerManager.isTimerRunning, "Timer should be running initially")
        XCTAssertTrue(mockTimerManager.hasStartedSession, "Session should have started initially")
        
        mockTimerManager.stopTimer()

        XCTAssertTrue(mockTimerManager.stopTimerCallCount == 1, "stopTimer should be called once")
        XCTAssertFalse(mockTimerManager.isTimerRunning, "isTimerRunning should be false after stopping")
    }

    func testResetTimer() {
        let mockTimer = DefaultTimer(rounds: 4, minutes: 25, seconds: 0, breakMinutes: 5, breakSeconds: 0)
        let mockTimerManager = MockTimerManager(timer: mockTimer)

        mockTimerManager.startTimer()
        mockTimerManager.stopTimer() // Reset button is only visible to the user when the timer is paused
        mockTimerManager.tickTimer() // To ensure the timer actually ticks in case the computer calls start and stop too quickly
        mockTimerManager.resetTimer()

        XCTAssertTrue(mockTimerManager.resetTimerCallCount == 1, "resetTimer should be called once")
        XCTAssertEqual(mockTimerManager.timer.minutes, mockTimer.originalMinutes, "Timer minutes should reset to original")
        XCTAssertEqual(mockTimerManager.timer.seconds, mockTimer.originalSeconds, "Timer seconds should reset to original")
        XCTAssertFalse(mockTimerManager.hasStartedSession, "hasStartedSession should be false after reset")
        XCTAssertEqual(mockTimerManager.completedRounds, 0, "completedRounds should be 0 after reset")
        XCTAssertEqual(mockTimerManager.completedBreaks, 0, "completedBreaks should be 0 after reset")
    }

    func testTickTimer() {
        let mockTimer = DefaultTimer(minutes: 1, seconds: 1)
        let mockTimerManager = MockTimerManager(timer: mockTimer)

        mockTimerManager.tickTimer()

        XCTAssertEqual(mockTimerManager.timer.seconds, 0, "Seconds should decrement by 1")
        
        mockTimerManager.tickTimer() // timer should be 0 minutes : 59 seconds
        
        XCTAssertEqual(mockTimerManager.timer.minutes, 0, "Minutes should reach 0")
    }

    func testProcessRoundCompletion() {
        let mockTimer = DefaultTimer(rounds: 2, minutes: 0, seconds: 0, breakMinutes: 1, breakSeconds: 0)
        let mockTimerManager = MockTimerManager(timer: mockTimer)

        mockTimerManager.processRoundCompletion()

        XCTAssertTrue(mockTimerManager.completedRounds == 1, "completedRounds should increment")
        XCTAssertFalse(mockTimerManager.isFocusInterval, "isFocusInterval should be false after round completion")
    }

    func testResetTimerForNextRound() {
        let mockTimer = DefaultTimer(minutes: 25, seconds: 0)
        let mockTimerManager = MockTimerManager(timer: mockTimer)

        mockTimerManager.resetTimerForNextRound()

        XCTAssertTrue(mockTimerManager.resetTimerForNextRoundCalled, "resetTimerForNextRound should be called")
        XCTAssertEqual(mockTimerManager.timer.minutes, mockTimer.originalMinutes, "Timer minutes should reset to original for next round")
        XCTAssertEqual(mockTimerManager.timer.seconds, mockTimer.originalSeconds, "Timer seconds should reset to original for next round")
    }

    func testResetTimerForBreak() {
        let mockTimer = DefaultTimer(rounds: 4, minutes: 25, seconds: 0, breakMinutes: 5, breakSeconds: 0)
        let mockTimerManager = MockTimerManager(timer: mockTimer)

        mockTimerManager.resetTimerForBreak()

        XCTAssertTrue(mockTimerManager.resetTimerForBreakCalled, "resetTimerForBreak should be called")
        XCTAssertEqual(mockTimerManager.timer.minutes, mockTimer.originalBreakMinutes, "Timer minutes should reset to break time")
        XCTAssertEqual(mockTimerManager.timer.seconds, mockTimer.originalBreakSeconds, "Timer seconds should reset to break time")
    }
}
