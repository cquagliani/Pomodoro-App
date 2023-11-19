//
//  TimerButtonStyle.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct TimerButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var currentMode
    var primaryColorLight: Color = Color(red: 250/255, green: 249/255, blue: 246/255)
    var primaryColorDark: Color = Color(red: 44/255, green: 51/255, blue: 51/255)
    var foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color = currentMode == .dark ? primaryColorLight : primaryColorDark
        
        configuration.label
            .fontWeight(.semibold)
            .fontDesign(.monospaced)
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .overlay(darkOverlayIfNeeded)
            .cornerRadius(15)
            .shadow(color: configuration.isPressed ? .gray : .clear, radius: 10)
            .scaleEffect(configuration.isPressed ? 0.75 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
    
    private var darkOverlayIfNeeded: some View {
        Group {
            if currentMode == .dark {
                Color.black.opacity(0.05)
            }
        }
    }
}


