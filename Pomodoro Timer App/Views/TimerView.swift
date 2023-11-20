//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var colorMode: AppColorMode = .system

    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            
            if timerManager.sessionCompleted {
                TimerCompletedView()
            } else {
                VStack {
                    header
                    Spacer()
                    timerCircle
                    Spacer()
                    roundsEmojisView
                    if !timerManager.hideTimerButtons {
                        controlButtons
                    }
                    Spacer()
                }
            }
        }
        .modifier(ColorModeViewModifier(mode: colorMode))
    }
    
    private var header: some View {
        VStack {
            Text("Pomodoro Timer")
                .foregroundColor(Color.theme.invertedPrimary)
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            
            Button(action: toggleColorMode) {
                Image(systemName: colorMode == .light ? "moon.stars" : "sun.max")
                    .imageScale(.medium)
                    .font(.system(size: 30))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)
        }
        .foregroundColor(Color.theme.invertedPrimary)
    }
    
    private func toggleColorMode() {
        colorMode = (colorMode == .light) ? .dark : .light
    }

    private var timerCircle: some View {
        let timerType: String = timerManager.isFocusInterval ? "Focus" : "Break"
        let timeString: String = String(format: "%02dm:%02ds", timerManager.timer.minutes, timerManager.timer.seconds)
        
        return ZStack {
            Circle()
                .foregroundColor(Color.theme.invertedPrimary)
            VStack {
                Text(timerType)
                    .foregroundColor(Color.theme.timerSubtitle)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                Text(timeString)
                    .foregroundColor(Color.theme.primaryColor)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
        }
        .padding(.horizontal, 60)
    }
    
    private var roundsEmojisView: some View {
        VStack {
            Text("Rounds")
                .foregroundColor(Color.theme.roundSubtitle)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .padding(.bottom, 4)
            
            HStack(spacing: 10) {
                ForEach(emojisForRoundsAndBreaks.indices, id: \.self) { index in
                    Text(emojisForRoundsAndBreaks[index])
                        .font(.system(size: index % 2 == 0 ? 28 : 16)) // Break session emojis are displayed smaller than focus session emojis
                }
            }
        }
    }
    
    private var emojisForRoundsAndBreaks: [String] {
        var emojis: [String] = []

        for index in 0..<timerManager.timer.rounds {
            emojis.append(emojiForRound(index: index))
            emojis.append(emojiForBreak(index: index))
        }

        return emojis
    }

    private func emojiForRound(index: Int) -> String {
        return index < timerManager.completedRounds ? "✅" : "📚"
    }

    private func emojiForBreak(index: Int) -> String {
        if (index + 1) % 4 == 0 { // Every 4th break is a long break
            return index < timerManager.completedBreaks ? "🎉" : "🏆"
        } else {
            return index < timerManager.completedBreaks ? "✔️" : "☕️"
        }
    }


    private var controlButtons: some View {
        HStack {
            if timerManager.isTimerRunning {
                stopButton
            } else if timerManager.hasStartedSession { // Only display the reset button if the timer session has begun
                startButton
                resetButton
            } else {
                startButton
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
        .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.greenAccent))
    }

    private var stopButton: some View {
        Button("Pause") {
            timerManager.stopTimer()
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.redAccent))
        
    }
    
    private var resetButton: some View {
        Button("Reset") {
            timerManager.resetTimer()
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.yellowAccent))
    }
}
