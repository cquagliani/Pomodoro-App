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
    
    func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.beginBackgroundTask()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.endBackgroundTask()
        }
    }
    
    func removeLifecycleObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
