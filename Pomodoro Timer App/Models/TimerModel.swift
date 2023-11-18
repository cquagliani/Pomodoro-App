//
//  TimerModel.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import Foundation

protocol PomodoroTimer {
    var minutes: Int { get set }
    var seconds: Int { get set }
    var rounds: Int { get set }
    var breakMinutes: Int { get set }
    var breakSeconds: Int { get set }
}

struct DefaultTimer: PomodoroTimer {
    var minutes: Int
    var seconds: Int
    var rounds: Int
    var breakMinutes: Int
    var breakSeconds: Int
    
    init(minutes: Int = 25, seconds: Int = 0, rounds: Int = 4, breakMinutes: Int = 5, breakSeconds: Int = 0) {
        self.minutes = max(0, min(minutes, 60))
        self.seconds = max(0, seconds)
        self.rounds = max(0, min(rounds, 10))
        self.breakMinutes = max(0, min(breakMinutes, 60))
        self.breakSeconds = max(0, breakSeconds)
    }
}

