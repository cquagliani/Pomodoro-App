//
//  TimerViewModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI
import Combine
import ActivityKit

protocol TimerManagerProtocol: ObservableObject {
    var timer: DefaultTimer { get set }
    var completedRounds: Int { get set }
    var completedBreaks: Int { get set }
    var isTimerRunning: Bool { get set }
    var hasStartedSession: Bool { get set }
    var hideTimerButtons: Bool { get set }

    func startTimer()
    func stopTimer()
    func resetTimer()
    func tickTimer()
    func processRoundCompletion()
    func resetTimerForNextRound()
    func resetTimerForBreak()
    func resetTimerForLongBreak()
}

class TimerManager: TimerManagerProtocol, ObservableObject {
    @Published var timer: DefaultTimer
    @Published var completedRounds = 0
    @Published var completedBreaks = 0
    @Published var isTimerRunning = false
    @Published var hasStartedSession = false
    @Published var sessionCompleted = false
    @Published var hideTimerButtons = false
    @Published var currentActivity: Activity<TimerAttributes>? = nil
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
        
        Task {
            do {
                try await startLiveActivity()
            } catch {
                print("Error starting Live Activity: \(error)")
            }
            
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timerSubscription?.cancel()
        
        Task {
            await endLiveActivity()
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
        
        Task {
            do {
                try await updateLiveActivity()
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

    private func formatTimeRemaining() -> String {
        return String(format: "%02dm:%02ds", timer.minutes, timer.seconds)
    }
}
