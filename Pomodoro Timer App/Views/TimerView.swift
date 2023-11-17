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
            Text(timeString)
                .foregroundColor(.white)
                .font(.title.bold().monospaced())
        }
        .padding(.horizontal, 60)
    }
    
    private var roundsEmojisView: some View {
        HStack(spacing: 3) {
            ForEach(0..<timerManager.timer.rounds, id: \.self) { index in
                Text(index < timerManager.completedRounds ? "✅" : "⬛️")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        }
    }

    private var controlButtons: some View {
        HStack {
            startButton
            Spacer()
            stopButton
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

    private var timeString: String {
        String(format: "%02dm:%02ds", timerManager.timer.minutes, timerManager.timer.seconds)
    }
}

#Preview {
    TimerView()
}
