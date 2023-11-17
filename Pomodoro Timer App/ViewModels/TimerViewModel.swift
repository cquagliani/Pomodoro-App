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
    var isFocusInterval = true
    var timerSubscription: AnyCancellable?

    init(timer: DefaultTimer) {
        self.timer = timer
    }

    func startTimer() {
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tickTimer()
        }
    }

    func stopTimer() {
        timerSubscription?.cancel()
    }
    
    func resetTimer() {
        timerSubscription?.cancel()

        timer.minutes = 0 
        timer.seconds = 5
        completedRounds = 0
        isFocusInterval = true
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
                if completedRounds < timer.rounds {
                    completedRounds += 1
                    isFocusInterval = false
                    resetTimerForBreak()
                    startTimer()
                }
            } else {
                completedBreaks += 1
                isFocusInterval = true
                resetTimerForNextRound()
                if completedRounds < timer.rounds {
                    startTimer()
                }
            }
        }

    private func resetTimerForNextRound() {
        timer.minutes = 0
        timer.seconds = 5
    }
    
    private func resetTimerForBreak() {
        timer.minutes = timer.breakMinutes
        timer.seconds = timer.breakSeconds
    }

}
