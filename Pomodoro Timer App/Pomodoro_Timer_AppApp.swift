//
//  Pomodoro_Timer_AppApp.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

@main
struct Pomodoro_Timer_AppApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .defaultAppStorage(UserDefaults(suiteName: "group.com.pomodoro-timer")!)
        }
    }
}
