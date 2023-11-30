//
//  TimerAttributes.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/21/23.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public typealias TimerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var timeRemaining: String
        var timerType: String
        var completedRounds: Int
        var completedBreaks: Int
        var progress: Float
    }
}
