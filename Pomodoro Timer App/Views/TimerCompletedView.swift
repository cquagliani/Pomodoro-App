//
//  TimerCompletedView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/19/23.
//

import SwiftUI

struct TimerCompletedView: View {
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                emojiView
                completionMessage
                VStack {
                    restartButton
                    goHome
                }
                Spacer()
            }
            .padding(.horizontal, UIConstants.horizontalPadding)
        }
    }

    private var emojiView: some View {
        Text("🏆")
            .font(.system(size: UIConstants.largeEmojiSize))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }

    private var completionMessage: some View {
        Text("Way to go, your timer has completed!")
            .foregroundColor(Color.theme.invertedPrimary)
            .font(.title3)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
    }

    private var restartButton: some View {
        Button("Restart Timer") {
            timerManager.resetTimer()
            timerManager.startTimer()
            timerManager.hideTimerButtons = false
            timerManager.sessionCompleted = false
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.yellowAccent))
        .frame(maxWidth: UIConstants.maxControlButtonWidth)
        .padding(.top, UIConstants.buttonTopPadding)
    }
    
    private var goHome: some View {
        Button("Go home") {
            timerManager.resetTimer()
            timerManager.hideTimerButtons = false
            timerManager.sessionCompleted = false
        }
        .foregroundColor(Color.blue)
        .font(.timerSubtitle)
        .padding(.top, UIConstants.buttonTopPadding)
    }
}


#Preview {
    TimerCompletedView()
}
