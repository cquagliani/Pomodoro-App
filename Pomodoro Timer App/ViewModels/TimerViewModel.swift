//
//  TimerViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
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

    private func tickTimer() {
        if timer.seconds > 0 {
            timer.seconds -= 1
        } else if timer.minutes > 0 {
            timer.minutes -= 1
            timer.seconds = 59
        } else {
            processRoundCompletion()
        }
    }

    private func processRoundCompletion() {
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

    private func resetTimerForNextRound() {
        timer.minutes = timer.originalMinutes
        timer.seconds = timer.originalSeconds
    }
    
    private func resetTimerForBreak() {
        timer.minutes = timer.originalBreakMinutes
        timer.seconds = timer.originalBreakSeconds
    }
}
