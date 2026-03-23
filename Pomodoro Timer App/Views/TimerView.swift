//
//  Timer.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var colorMode: AppColorMode
    @Binding var focusEmoji: String
    @Binding var breakEmoji: String
    @Binding var longBreakEmoji: String

    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)

            if timerManager.sessionCompleted {
                TimerCompletedView()
            } else {
                VStack {
                    Spacer()
                    timerContainer
                    progressBar
                    Spacer()
                    roundsEmojisView
                    if !timerManager.hideTimerButtons {
                        controlButtons
                    }
                    Spacer()
                }
            }
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

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.theme.invertedPrimary.opacity(0.3))

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.theme.greenAccent)
                    .frame(width: geometry.size.width * CGFloat(timerManager.progress))
                    .animation(.linear(duration: 0.3), value: timerManager.progress)
            }
        }
        .frame(maxWidth: UIConstants.maxTimerContainerWidth * 0.8, maxHeight: 6)
        .padding(.top, 8)
        .padding(.horizontal, UIConstants.horizontalPadding)
    }

    private var roundsEmojisView: some View {
        RoundsEmojisView(
            rounds: timerManager.timer.rounds,
            completedRounds: timerManager.completedRounds,
            completedBreaks: timerManager.completedBreaks,
            focusEmoji: focusEmoji,
            breakEmoji: breakEmoji,
            longBreakEmoji: longBreakEmoji
        )
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

// Extracted to its own view so SwiftUI only re-evaluates when
// rounds/completedRounds/completedBreaks/emojis actually change,
// not on every timer tick.
private struct RoundsEmojisView: View {
    let rounds: Int
    let completedRounds: Int
    let completedBreaks: Int
    let focusEmoji: String
    let breakEmoji: String
    let longBreakEmoji: String

    var body: some View {
        VStack {
            Text("Rounds")
                .foregroundColor(Color.theme.roundSubtitle)
                .font(.timerSubtitle)
                .padding(.bottom, 4)

            HStack(spacing: 10) {
                ForEach(emojis.indices, id: \.self) { index in
                    Text(emojis[index])
                        .font(.system(size: index % 2 == 0 ? UIConstants.roundsEmojiSize : UIConstants.breaksEmojiSize))
                }
            }
        }
        .padding(.top, 16)
    }

    private var emojis: [String] {
        var result: [String] = []
        for index in 0..<rounds {
            result.append(index < completedRounds ? "✅" : focusEmoji)
            if (index + 1) % 4 == 0 {
                result.append(index < completedBreaks ? "🎉" : longBreakEmoji)
            } else {
                result.append(index < completedBreaks ? "✔️" : breakEmoji)
            }
        }
        return result
    }
}

