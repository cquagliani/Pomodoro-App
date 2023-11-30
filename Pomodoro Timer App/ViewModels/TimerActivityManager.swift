//
//  TimerActivityManager.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/27/23.
//

import ActivityKit
import UIKit

class TimerActivityManager {
    var currentActivity: Activity<TimerAttributes>? = nil

    private var minutes: Int = 0
    private var seconds: Int = 0
    private var progress: Float = 0
    private var timerType: String = ""
    private var completedRounds: Int = 0
    private var completedBreaks: Int = 0

    func startLiveActivity() async throws {
        let attributes = TimerAttributes()
        let status = TimerAttributes.ContentState(
            timeRemaining: formatTimeRemaining(),
            timerType: timerType,
            completedRounds: completedRounds,
            completedBreaks: completedBreaks,
            progress: progress
        )
        let content = ActivityContent(state: status, staleDate: nil)

        let activity = try Activity<TimerAttributes>.request(attributes: attributes, content: content, pushType: nil)
        DispatchQueue.main.async {
            self.currentActivity = activity
        }
        try await updateLiveActivity()
    }

    func updateLiveActivity() async throws {
        guard let activity = currentActivity else { return }

        let newState = TimerAttributes.ContentState(
            timeRemaining: formatTimeRemaining(),
            timerType: timerType,
            completedRounds: completedRounds,
            completedBreaks: completedBreaks,
            progress: progress
        )
        let updatedContent = ActivityContent(state: newState, staleDate: nil)
        await activity.update(updatedContent)
    }

    func endLiveActivity() async {
        guard let activity = currentActivity else { return }
        await activity.end(activity.content, dismissalPolicy: .immediate)

        DispatchQueue.main.async {
            self.currentActivity = nil
        }
    }

    func setTimer(minutes: Int, seconds: Int, progress: Float, timerType: String, completedRounds: Int, completedBreaks: Int) {
        self.minutes = minutes
        self.seconds = seconds
        self.progress = progress
        self.timerType = timerType
        self.completedRounds = completedRounds
        self.completedBreaks = completedBreaks
    }

    private func formatTimeRemaining() -> String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
