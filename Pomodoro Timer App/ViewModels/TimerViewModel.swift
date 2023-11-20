//
//  TimerViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import Foundation
import Combine

protocol TimerManagerProtocol: ObservableObject {
    var timer: DefaultTimer { get set }
    var completedRounds: Int { get set }
    var completedBreaks: Int { get set }
    var isTimerRunning: Bool { get set }
    var hasStartedSession: Bool { get set }

    func startTimer()
    func stopTimer()
    func resetTimer()
    func tickTimer()
    func processRoundCompletion()
    func resetTimerForNextRound()
    func resetTimerForBreak()
}

class TimerManager: TimerManagerProtocol, ObservableObject {
    @Published var timer: DefaultTimer
    @Published var completedRounds = 0
    @Published var completedBreaks = 0
    @Published var isTimerRunning = false
    @Published var hasStartedSession = false
    var isFocusInterval = true
    var timerSubscription: AnyCancellable?

    init(timer: DefaultTimer) {
        self.timer = timer
    }

    func startTimer() {
        isTimerRunning = true
        hasStartedSession = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tickTimer()
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timerSubscription?.cancel()
    }
    
    func resetTimer() {
        hasStartedSession = false
        isFocusInterval = true
        timerSubscription?.cancel()

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
        timer.minutes = timer.originalMinutes
        timer.seconds = timer.originalSeconds
    }
    
    func resetTimerForBreak() {
        timer.minutes = timer.originalBreakMinutes
        timer.seconds = timer.originalBreakSeconds
    }
}
