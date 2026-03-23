//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

enum Tab {
    case timer
    case metrics
    case settings
}

struct ContentView: View {
    @State private var colorMode: AppColorMode
    @State private var selectedTab: Tab = .timer
    @State private var focusEmoji: String
    @State private var breakEmoji: String
    @State private var longBreakEmoji: String

    @StateObject private var timerManager: TimerManager

    init() {
        let settings = SharedUserDefaults.shared.getSettings()
        _colorMode = State(initialValue: settings.colorMode)
        _focusEmoji = State(initialValue: settings.focusEmoji)
        _breakEmoji = State(initialValue: settings.breakEmoji)
        _longBreakEmoji = State(initialValue: settings.longBreakEmoji)
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
        TabView(selection: $selectedTab) {
            TimerView(
                colorMode: $colorMode,
                focusEmoji: $focusEmoji,
                breakEmoji: $breakEmoji,
                longBreakEmoji: $longBreakEmoji
            )
            .tabItem { Label("Timer", systemImage: "timer") }
            .tag(Tab.timer)

            MetricsView()
                .tabItem { Label("Metrics", systemImage: "chart.dots.scatter") }
                .tag(Tab.metrics)

            SettingsView(
                colorMode: $colorMode,
                focusEmoji: $focusEmoji,
                breakEmoji: $breakEmoji,
                longBreakEmoji: $longBreakEmoji,
                timerManager: timerManager,
                selectedTab: $selectedTab
            )
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
        .tint(Color.theme.invertedPrimary)
        .environmentObject(timerManager)
        .modifier(ColorModeViewModifier(mode: colorMode))
    }
}

#Preview {
    ContentView()
}
