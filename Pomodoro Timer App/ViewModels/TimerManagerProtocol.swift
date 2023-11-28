//
//  TimerManagerProtocol.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/27/23.
//

import Foundation

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
