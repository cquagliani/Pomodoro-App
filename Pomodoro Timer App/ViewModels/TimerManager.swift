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
    private var endDate: Date?
    private var pausedRemainingSeconds: Int = 0

    init(timer: DefaultTimer) {
        self.timer = timer
        backgroundTaskManager.setupLifecycleObservers()
    }

    func startTimer() {
        let isResuming = hasStartedSession
        isTimerRunning = true
        hasStartedSession = true

        // Compute the target end date from current remaining time
        let remainingSeconds: Int
        if pausedRemainingSeconds > 0 {
            remainingSeconds = pausedRemainingSeconds
            pausedRemainingSeconds = 0
        } else {
            remainingSeconds = (timer.minutes * 60) + timer.seconds
        }
        totalTimeInSeconds = remainingSeconds
        endDate = Date.now.addingTimeInterval(TimeInterval(remainingSeconds))

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
            progress: calculateProgress(),
            timerType: isFocusInterval ? "Focus" : "Break",
            completedRounds: completedRounds,
            completedBreaks: completedBreaks
        )

        if isResuming {
            // Activity already exists — just update it
            liveActivityTask?.cancel()
            liveActivityTask = Task {
                do {
                    try await activityManager.updateLiveActivity()
                } catch {
                    print("Error updating Live Activity: \(error)")
                }
            }
        } else {
            // First start of session — create the Live Activity
            Task {
                do {
                    try await activityManager.startLiveActivity()
                } catch {
                    print("Error starting Live Activity: \(error)")
                }
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false

        // Preserve remaining time so resume can pick up where we left off
        if let endDate {
            pausedRemainingSeconds = max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))
        }
        self.endDate = nil

        backgroundTaskManager.endBackgroundTask()
        timerTask?.cancel()
        liveActivityTask?.cancel()

        // Update the Live Activity to reflect paused state — don't end it
        activityManager.setTimer(
            minutes: timer.minutes,
            seconds: timer.seconds,
            progress: calculateProgress(),
            timerType: isFocusInterval ? "Focus" : "Break",
            completedRounds: completedRounds,
            completedBreaks: completedBreaks
        )
        liveActivityTask = Task {
            do {
                try await activityManager.updateLiveActivity()
            } catch {
                print("Error updating Live Activity on pause: \(error)")
            }
        }
    }

    func resetTimer() {
        hasStartedSession = false
        isTimerRunning = false
        isFocusInterval = true
        timerTask?.cancel()
        liveActivityTask?.cancel()
        endDate = nil
        pausedRemainingSeconds = 0

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

        // End the Live Activity when the session is fully reset
        Task {
            await activityManager.endLiveActivity()
        }
    }

    func tickTimer() {
        guard let endDate else { return }

        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))
        timer.minutes = remaining / 60
        timer.seconds = remaining % 60

        if remaining == 0 {
            processRoundCompletion()
            return
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
        guard totalTimeInSeconds > 0 else { return 0 }
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

                // End the Live Activity since the full session is complete
                liveActivityTask?.cancel()
                Task {
                    await activityManager.endLiveActivity()
                }

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
