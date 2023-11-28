//
//  FontStyles.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/27/23.
//

import SwiftUI

extension Font {
    static var timerTitle: Font {
        .system(size: 36, weight: .bold, design: .monospaced)
    }

    static var timerSubtitle: Font {
        .system(size: 16, weight: .semibold, design: .monospaced)
    }

    static var largeImageIcon: Font {
        .system(size: 30)
    }
}
