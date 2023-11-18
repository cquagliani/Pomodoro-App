//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager
    
    init() {
        let timer = DefaultTimer(minutes: 25, seconds: 0, breakMinutes: 5, breakSeconds: 0)
        _timerManager = StateObject(wrappedValue: TimerManager(timer: timer))
    }

    var body: some View {
        ZStack {
            Color(red: 250/255, green: 249/255, blue: 246/255).edgesIgnoringSafeArea(.all)
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
            VStack {
                let timerType: String = timerManager.isFocusInterval ? "Focus" : "Break"
                Text(timerType)
                    .foregroundColor(.white)
                    .foregroundColor(.black).opacity(0.6)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                Text(timeString)
                    .foregroundColor(.white)
                    .font(.title.bold().monospaced())
            }
        }
        .padding(.horizontal, 60)
    }
    
    private var roundsEmojisView: some View {
        VStack {
            Text("Rounds")
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.black).opacity(0.6)
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
                startButton
                resetButton
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
        .buttonStyle(TimerButtonStyle(backgroundColor: .black, foregroundColor: .green))
    }

    private var stopButton: some View {
        Button("Pause") {
            timerManager.stopTimer()
        }
        .buttonStyle(TimerButtonStyle(backgroundColor: .black, foregroundColor: .red))
        
    }
    
    private var resetButton: some View {
        Button("Reset") {
            timerManager.resetTimer()
        }
        .buttonStyle(TimerButtonStyle(backgroundColor: .black, foregroundColor: .yellow))
    }

    private var timeString: String {
        String(format: "%02dm:%02ds", timerManager.timer.minutes, timerManager.timer.seconds)
    }
}
