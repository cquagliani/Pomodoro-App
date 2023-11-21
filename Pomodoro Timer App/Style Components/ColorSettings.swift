//
//  ColorSettings.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/18/23.
//

import SwiftUI

enum AppColorMode: String {
    case light
    case dark
    case system
}

struct ColorModeViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let mode: AppColorMode

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, colorSchemeForMode(mode))
    }

    private func colorSchemeForMode(_ mode: AppColorMode) -> ColorScheme {
        switch mode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return colorScheme == .dark ? .dark : .light
        }
    }
}

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let primaryColor = Color("MainColor")
    let invertedPrimary = Color("InvertedMain")
    let timerSubtitle = Color("TimerSubtitle")
    let roundSubtitle = Color("RoundSubtitle")
    let greenAccent = Color("GreenAccent")
    let redAccent = Color("RedAccent")
    let yellowAccent = Color("YellowAccent")
    let grayAccent = Color("GrayAccent")
}
