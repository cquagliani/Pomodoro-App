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
            .padding(.horizontal, 45)
        }
    }

    private var emojiView: some View {
        Text("🏆")
            .imageScale(.medium)
            .font(.system(size: 60))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }

    private var completionMessage: some View {
        Text("Way to go, your timer has completed!")
            .foregroundColor(Color.theme.invertedPrimary)
            .font(.title3)
            .fontWeight(.bold)
            .fontDesign(.monospaced)
            .multilineTextAlignment(.center)
    }

    private var restartButton: some View {
        Button("Restart Timer") {
            timerManager.resetTimer()
            timerManager.startTimer()
            timerManager.sessionCompleted = false
        }
        .buttonStyle(TimerButtonStyle(foregroundColor: Color.theme.yellowAccent))
        .padding(.top, 25)
    }
    
    private var goHome: some View {
        Button("Go home") {
            timerManager.resetTimer()
            timerManager.sessionCompleted = false
        }
        .foregroundColor(Color.blue)
        .font(.system(size: 16))
        .fontWeight(.bold)
        .fontDesign(.monospaced)
        .padding(.top, 15)
    }
}

#Preview {
    TimerCompletedView()
}
