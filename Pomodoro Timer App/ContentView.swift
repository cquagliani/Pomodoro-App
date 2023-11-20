//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager(
        timer: DefaultTimer(
            rounds: 4,
            minutes: 0,
            seconds: 2,
            breakMinutes: 0,
            breakSeconds: 2
        )
    )
    
    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            if timerManager.sessionCompleted {
                TimerCompletedView()
                    .environmentObject(timerManager)
            } else {
                TimerView()
                    .environmentObject(timerManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
