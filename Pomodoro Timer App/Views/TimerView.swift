//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager

    init(timer: DefaultTimer = DefaultTimer()) {
        _timerManager = StateObject(wrappedValue: TimerManager(timer: timer))
    }

    var body: some View {
        ZStack {
            Color(red: 237/255, green: 238/255, blue: 240/255).edgesIgnoringSafeArea(.all)
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
                .padding(.horizontal, 60)
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
            emojis.append(index < timerManager.completedRounds ? "✅" : "⬛️")
            
            if index < timerManager.timer.rounds - 1 {
                emojis.append(index < timerManager.completedBreaks ? "✔️" : "☕️")
            }
        }
        
        return emojis
    }


    private var controlButtons: some View {
        HStack {
            startButton
            Spacer()
            stopButton
            Spacer()
            resetButton
        }
        .padding(.horizontal, 85)
        .padding(.vertical, 15)
    }

    private var startButton: some View {
        Button("Start") {
            timerManager.startTimer()
        }
        .buttonStyle(TimerButtonStyle(backgroundColor: .black, foregroundColor: .green))
    }

    private var stopButton: some View {
        Button("Stop") {
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

#Preview {
    TimerView()
}
