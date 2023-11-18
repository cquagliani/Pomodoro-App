//
//  TimerButtonStyle.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .fontDesign(.monospaced)
            .frame(width: 100, height: 50)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: configuration.isPressed ? .gray : .clear, radius: 10)
            .scaleEffect(configuration.isPressed ? 0.75 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}
