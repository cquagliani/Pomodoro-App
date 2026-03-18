//
//  TimerViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

class TimerManager: TimerManagerProtocol, ObservableObject {
    private let activityManager = TimerActivityManager()
    private let backgroundTaskManager = BackgroundTaskManager()
    
    @Published var timer: DefaultTimer
    @Published var completedRounds = 0
    @Published var completedBreaks = 0
    @Published var isTimerRunning = false
    @Published var hasStartedSession = false
    @Published var sessionCompleted = false
    @Published var hideTimerButtons = false
    @Published var isFocusInterval = true
    private var timerTask: Task<Void, Never>?
    private var liveActivityTask: Task<Void, Never>?
    private var totalTimeInSeconds: Int = 0

    init(timer: DefaultTimer) {
        self.timer = timer
        backgroundTaskManager.setupLifecycleObservers()
    }

    func startTimer() {
        isTimerRunning = true
        hasStartedSession = true
        totalTimeInSeconds = (timer.minutes * 60) + timer.seconds
        backgroundTaskManager.beginBackgroundTask()
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.tickTimer()
                }
            }
        }
        activityManager.setTimer(
            minutes: timer.minutes,
            seconds: timer.seconds,
            progress: 0,
            timerType: isFocusInterval ? "Focus" : "Break",
            completedRounds: completedRounds,
            completedBreaks: completedBreaks
        )
        
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
        timerTask?.cancel()
        liveActivityTask?.cancel()
        
        Task {
            await activityManager.endLiveActivity()
        }
    }
    
    func resetTimer() {
        hasStartedSession = false
        isFocusInterval = true
        timerTask?.cancel()

        timer.minutes = timer.originalMinutes
        timer.seconds = timer.originalSeconds
        completedRounds = 0
        completedBreaks = 0
        totalTimeInSeconds = (timer.minutes * 60) + timer.seconds
        activityManager.setTimer(
            minutes: timer.minutes,
            seconds: timer.seconds,
            progress: 0,
            timerType: isFocusInterval ? "Focus" : "Break",
            completedRounds: completedRounds,
            completedBreaks: completedBreaks
        )
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
        let progress = calculateProgress()
        activityManager.setTimer(
            minutes: timer.minutes,
            seconds: timer.seconds,
            progress: progress,
            timerType: isFocusInterval ? "Focus" : "Break",
            completedRounds: completedRounds,
            completedBreaks: completedBreaks
        )
        
        liveActivityTask?.cancel()
        liveActivityTask = Task {
            do {
                try await activityManager.updateLiveActivity()
            } catch {
                print("Error updating Live Activity: \(error)")
            }
        }
    }
    
    private func calculateProgress() -> Float {
        let remainingTimeInSeconds = (timer.minutes * 60) + timer.seconds
        let progress = Float(totalTimeInSeconds - remainingTimeInSeconds) / Float(totalTimeInSeconds)
        return max(0.0, min(progress, 1.0))
    }
    
    func processRoundCompletion() {
        stopTimer()
        
        let notificationTitle: String
        let notificationBody: String

        if isFocusInterval {
            completedRounds += 1
            isFocusInterval = false

            notificationTitle = "Focus Round Complete"
            notificationBody = "Time for a break!"

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
                
                notificationTitle = "Break Complete"
                notificationBody = "Ready to focus? \(timer.rounds - completedRounds) rounds to go!"
                
            } else { // End of the last break
                
                notificationTitle = "Pomodoro Session Complete"
                notificationBody = "Congrats! You made it to the end of your pomodoro session."
                
                NotificationManager.shared.scheduleNotification(title: notificationTitle, body: notificationBody)
                
                hideTimerButtons = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.sessionCompleted = true
                }
                return
            }
        }

        // Schedule the notification
        NotificationManager.shared.scheduleNotification(title: notificationTitle, body: notificationBody)

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
    
    deinit {
        backgroundTaskManager.removeLifecycleObservers()
    }
}
