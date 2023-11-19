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
}

struct ColorModeViewModifier: ViewModifier {
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
        }
    }
}
