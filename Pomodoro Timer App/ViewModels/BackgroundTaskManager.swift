//
//  BackgroundTaskManager.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/27/23.
//

import UIKit

class BackgroundTaskManager {
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}
