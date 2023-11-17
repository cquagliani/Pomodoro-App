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
    
    init(minutes: Int = 0, seconds: Int = 5, rounds: Int = 4, breakMinutes: Int = 0, breakSeconds: Int = 2) {
        self.minutes = max(0, minutes)
        self.seconds = max(0, seconds)
        self.rounds = max(0, rounds)
        self.breakMinutes = max(0, breakMinutes)
        self.breakSeconds = max(0, breakSeconds)
    }
}
