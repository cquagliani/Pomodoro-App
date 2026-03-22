//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var colorMode: AppColorMode

    @StateObject private var timerManager: TimerManager

    init() {
        let settings = SharedUserDefaults.shared.getSettings()
        _colorMode = State(initialValue: settings.colorMode)
        _timerManager = StateObject(wrappedValue: TimerManager(
            timer: DefaultTimer(
                rounds: settings.rounds,
                minutes: settings.minutes,
                seconds: 0,
                breakMinutes: settings.breakMinutes,
                breakSeconds: 0,
                longBreakMinutes: settings.longBreakMinutes,
                longBreakSeconds: 0
            )
        ))
    }

    var body: some View {
        TimerView(colorMode: $colorMode)
            .environmentObject(timerManager)
    }
}

#Preview {
    ContentView()
}
