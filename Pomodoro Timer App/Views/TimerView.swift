//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.colorScheme) var currentMode
    @StateObject private var timerManager: TimerManager
    var primaryColorLight: Color = Color(red: 250/255, green: 249/255, blue: 246/255)
    var primaryColorDark: Color = Color(red: 44/255, green: 51/255, blue: 51/255)
    
    init() {
        let timer = DefaultTimer(minutes: 25, seconds: 0, breakMinutes: 5, breakSeconds: 0)
        _timerManager = StateObject(wrappedValue: TimerManager(timer: timer))
    }

    var body: some View {
        let primaryColor: Color = (currentMode == .dark) ? primaryColorDark : primaryColorLight
        
        ZStack {
            primaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                timerCircle
                Spacer()
                roundsEmojisView
                controlButtons
                Spacer()
            }
        }
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
                .foregroundColor(currentMode == .dark ? primaryColorLight : primaryColorDark)
            VStack {
                let timerType: String = timerManager.isFocusInterval ? "Focus" : "Break"
                Text(timerType)
                    .foregroundColor(currentMode == .dark ? primaryColorDark : primaryColorLight).opacity(0.6)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                Text(timeString)
                    .foregroundColor(currentMode == .dark ? primaryColorDark : primaryColorLight)
                    .font(.title.bold().monospaced())
            }
        }
        .padding(.horizontal, 60)
    }
    
    private var timeString: String {
        String(format: "%02dm:%02ds", timerManager.timer.minutes, timerManager.timer.seconds)
    }
    
    private var roundsEmojisView: some View {
        VStack {
            Text("Rounds")
                .foregroundColor(currentMode == .dark ? primaryColorLight : primaryColorDark).opacity(0.6)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .padding(.bottom, 4)
            HStack(spacing: 10) {
                ForEach(emojisForRoundsAndBreaks.indices, id: \.self) { index in
                    Text(emojisForRoundsAndBreaks[index])
                        .font(.system(size: index % 2 == 0 ? 28 : 16))
                }
            }
        }
    }

    private var emojisForRoundsAndBreaks: [String] {
        var emojis: [String] = []
        
        for index in 0..<timerManager.timer.rounds {
            emojis.append(index < timerManager.completedRounds ? "✅" : "📚")
            
            if index < timerManager.timer.rounds - 1 {
                emojis.append(index < timerManager.completedBreaks ? "✔️" : "☕️")
            }
        }
        
        return emojis
    }

    private var controlButtons: some View {
        HStack {
            if timerManager.isTimerRunning {
                stopButton
            } else {
                if timerManager.hasStartedSession { // Only display the reset button if the timer session has begun
                    startButton
                    resetButton
                } else {
                    startButton
                }
            }
        }
        .padding(.horizontal, 45)
        .padding(.vertical, 15)
    }

    private var startButton: some View {
        let label = timerManager.hasStartedSession ? "Resume" : "Start"
        return Button(label) {
            timerManager.startTimer()
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: .green))
    }

    private var stopButton: some View {
        Button("Pause") {
            timerManager.stopTimer()
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: .red))
        
    }
    
    private var resetButton: some View {
        Button("Reset") {
            timerManager.resetTimer()
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: .yellow))
    }
}
