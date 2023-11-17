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
    }
}
