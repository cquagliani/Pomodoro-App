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
                controlButtons
                Spacer()
            }
        }
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
            VStack {
                Text(timeString)
                    .foregroundColor(.white)
                    .font(.title.bold().monospaced())
                Text("\(timerManager.timer.rounds) rounds")
                    .foregroundColor(.white)
                    .font(.title3.bold().monospaced())
            }
        }
        .padding(.horizontal, 60)
    }

    private var controlButtons: some View {
        HStack {
            startButton
            Spacer()
            stopButton
        }
        .padding(.horizontal, 85)
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
