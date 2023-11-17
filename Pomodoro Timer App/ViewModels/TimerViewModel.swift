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

    private func tickTimer() {
        if timer.seconds > 0 {
            // Decrement seconds
            timer.seconds -= 1
        } else if timer.minutes > 0 {
            // Move to the next minute
            timer.minutes -= 1
            timer.seconds = 59
        } else {
            processRoundCompletion()
        }
    }

    private func processRoundCompletion() {
        stopTimer()
        // Add any visual feedback for round completion here

        if completedRounds < timer.rounds {
            completedRounds += 1

            if completedRounds < timer.rounds {
                resetTimerForNextRound()
                startTimer()
            }
        }
    }

    private func resetTimerForNextRound() {
        timer.minutes = 0
        timer.seconds = 5
    }

}
