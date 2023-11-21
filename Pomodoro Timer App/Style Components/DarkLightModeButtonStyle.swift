//
//  DarkLightModeButtonStyle.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/20/23.
//

import SwiftUI

struct DarkLightModeButtonStyle: ButtonStyle {
    @Binding var colorMode: AppColorMode
    var cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 30, height: 10, alignment: .center)
            .padding(10)
            .background(colorMode == .dark ? .black : .grayAccent)
            .foregroundColor(colorMode == .dark ? .yellow : .black)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.8), value: configuration.isPressed)
    }

}
