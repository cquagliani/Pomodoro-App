//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var colorMode: AppColorMode = .system
    @StateObject private var timerManager = TimerManager(
//        timer: DefaultTimer(
//            rounds: 4,
//            minutes: 25,
//            seconds: 0,
//            breakMinutes: 5,
//            breakSeconds: 0,
//            longBreakMinutes: 30,
//            longBreakSeconds: 0
//        )
        timer: DefaultTimer(
            rounds: 4,
            minutes: 0,
            seconds: 3,
            breakMinutes: 0,
            breakSeconds: 3,
            longBreakMinutes: 0,
            longBreakSeconds: 3
        )
    )
    
    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            if timerManager.sessionCompleted {
                TimerCompletedView()
                    .environmentObject(timerManager)
            } else {
                TimerView(colorMode: $colorMode)
                    .environmentObject(timerManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
