//
//  MockTimerModel.swift
//  Pomodoro Timer AppTests
//
//  Created by Chris Quagliani on 11/25/23.
//

import Foundation

protocol PomodoroTimer {
    var minutes: Int { get set }
    var seconds: Int { get set }
    var rounds: Int { get set }
    var breakMinutes: Int { get set }
    var breakSeconds: Int { get set }
    var longBreakMinutes: Int { get set }
    var longBreakSeconds: Int { get set }

    var originalRounds: Int { get set }
    var originalMinutes: Int { get set }
    var originalSeconds: Int { get set }
    var originalBreakMinutes: Int { get set }
    var originalBreakSeconds: Int { get set }
    var originalLongBreakMinutes: Int { get set }
    var originalLongBreakSeconds: Int { get set }
}

struct MockDefaultTimer: PomodoroTimer {
    var rounds: Int
    var minutes: Int
    var seconds: Int
    var breakMinutes: Int
    var breakSeconds: Int
    var longBreakMinutes: Int
    var longBreakSeconds: Int

    
    // Remembers original values: either default init values or custom user settings
    var originalRounds: Int
    var originalMinutes: Int
    var originalSeconds: Int
    var originalBreakMinutes: Int
    var originalBreakSeconds: Int
    var originalLongBreakMinutes: Int
    var originalLongBreakSeconds: Int
    
    init(rounds: Int = 4, minutes: Int = 25, seconds: Int = 0, breakMinutes: Int = 5, breakSeconds: Int = 0, longBreakMinutes: Int = 0, longBreakSeconds: Int = 5) {
        self.rounds = max(0, min(rounds, 10))
        self.minutes = max(0, min(minutes, 60))
        self.seconds = max(0, seconds)
        self.breakMinutes = max(0, min(breakMinutes, 60))
        self.breakSeconds = max(0, breakSeconds)
        self.longBreakMinutes = max(0, min(longBreakMinutes, 60))
        self.longBreakSeconds = max(0, longBreakSeconds)
        
        self.originalRounds = max(0, min(rounds, 10))
        self.originalMinutes = max(0, min(minutes, 60))
        self.originalSeconds = max(0, seconds)
        self.originalBreakMinutes = max(0, min(breakMinutes, 60))
        self.originalBreakSeconds = max(0, breakSeconds)
        self.originalLongBreakMinutes = max(0, min(longBreakMinutes, 60))
        self.originalLongBreakSeconds = max(0, longBreakSeconds)
    }
}

