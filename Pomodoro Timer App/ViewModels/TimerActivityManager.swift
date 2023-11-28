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

    func startLiveActivity() async throws {
        let attributes = TimerAttributes()
        let status = TimerAttributes.TimerStatus(timeRemaining: formatTimeRemaining())
        let content = ActivityContent(state: status, staleDate: nil)

        let activity = try Activity<TimerAttributes>.request(attributes: attributes, content: content, pushType: nil)
        DispatchQueue.main.async {
            self.currentActivity = activity
        }
        try await updateLiveActivity()
    }

    func updateLiveActivity() async throws {
        guard let activity = currentActivity else { return }
        
        let newState = TimerAttributes.ContentState(timeRemaining: formatTimeRemaining())
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

    private var minutes: Int = 0
    private var seconds: Int = 0

    func setTimer(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
    }

    private func formatTimeRemaining() -> String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

