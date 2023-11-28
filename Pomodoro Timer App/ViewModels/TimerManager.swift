//
//  TimerViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI
import Combine
import UIKit

class TimerManager: TimerManagerProtocol, ObservableObject {
    private let activityManager = TimerActivityManager()
    private let backgroundTaskManager = BackgroundTaskManager()
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    @Published var timer: DefaultTimer
    @Published var completedRounds = 0
    @Published var completedBreaks = 0
    @Published var isTimerRunning = false
    @Published var hasStartedSession = false
    @Published var sessionCompleted = false
    @Published var hideTimerButtons = false
    var isFocusInterval = true
    var timerSubscription: AnyCancellable?

    init(timer: DefaultTimer) {
        self.timer = timer
        setupLifecycleEventHandling()
    }

    func startTimer() {
        isTimerRunning = true
        hasStartedSession = true
        backgroundTaskManager.beginBackgroundTask()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tickTimer()
        }
        activityManager.setTimer(minutes: timer.minutes, seconds: timer.seconds)
        
        Task {
            do {
                try await activityManager.startLiveActivity()
            } catch {
                print("Error starting Live Activity: \(error)")
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        backgroundTaskManager.endBackgroundTask()
        timerSubscription?.cancel()
        
        Task {
            await activityManager.endLiveActivity()
        }
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
        activityManager.setTimer(minutes: timer.minutes, seconds: timer.seconds)
        
        Task {
            do {
                try await activityManager.updateLiveActivity()
            } catch {
                print("Error updating Live Activity: \(error)")
            }
        }
    }
    
    func processRoundCompletion() {
        stopTimer()

        if isFocusInterval {
            completedRounds += 1
            isFocusInterval = false
            
            if completedRounds % 4 == 0 {
                resetTimerForLongBreak()
            } else {
                resetTimerForBreak()
            }
            
        } else {
            completedBreaks += 1
            
            if completedRounds < timer.rounds {
                isFocusInterval = true
                resetTimerForNextRound()
            } else { // End of the last break
                hideTimerButtons = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in // Delay execution before setting sessionCompleted so user can see final emoji update
                    self?.sessionCompleted = true
                }
                return
            }
        }

        if !sessionCompleted {
            startTimer()
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
    
    func resetTimerForLongBreak() {
        timer.minutes = timer.originalLongBreakMinutes
        timer.seconds = timer.originalLongBreakSeconds
    }
    
    // Functions to persist timer while running in the background
    private func setupLifecycleEventHandling() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.backgroundTaskManager.beginBackgroundTask()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.backgroundTaskManager.endBackgroundTask()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
