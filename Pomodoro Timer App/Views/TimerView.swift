//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var colorMode: AppColorMode
    @State var showingSettings = false

    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            
            if timerManager.sessionCompleted {
                TimerCompletedView()
            } else {
                VStack {
                    header
                    Spacer()
                    timerContainer
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
            HStack {
                Spacer()
                Button(action: {
                    self.showingSettings.toggle()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.medium)
                        .font(.largeImageIcon)
                        .padding()
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(colorMode: $colorMode, showingSettings: $showingSettings, timerManager: timerManager)
            }
            .foregroundColor(Color.theme.invertedPrimary)
        }
    }
    
    private var timerContainer: some View {
        let timerType: String = timerManager.isFocusInterval ? "Focus" : "Break"
        let timeString: String = String(format: "%02dm:%02ds", timerManager.timer.minutes, timerManager.timer.seconds)

        return ZStack {
            Spacer()
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .foregroundColor(Color.theme.invertedPrimary)
                .frame(maxWidth: UIConstants.maxTimerContainerWidth, maxHeight: UIConstants.maxTimerContainerHeight)
            Spacer()
            VStack {
                Text(timerType)
                    .foregroundColor(Color.theme.timerSubtitle)
                    .font(.timerSubtitle)
                Text(timeString)
                    .foregroundColor(Color.theme.primaryColor)
                    .font(.timerTitle)
            }
        }
        .padding(.top, UIConstants.topPadding)
        .padding(.horizontal, UIConstants.horizontalPadding)
    }
    
    private var roundsEmojisView: some View {
        VStack {
            Text("Rounds")
                .foregroundColor(Color.theme.roundSubtitle)
                .font(.timerSubtitle)
                .padding(.bottom, 4)
            
            HStack(spacing: 10) {
                ForEach(emojisForRoundsAndBreaks.indices, id: \.self) { index in
                    Text(emojisForRoundsAndBreaks[index])
                        .font(.system(size: index % 2 == 0 ? UIConstants.roundsEmojiSize : UIConstants.breaksEmojiSize))
                }
            }
        }
        .padding(.top, 16)
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
        .padding(.horizontal, UIConstants.horizontalPadding)
        .padding(.top, 5)
        .frame(maxWidth: UIConstants.maxControlButtonWidth)
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

