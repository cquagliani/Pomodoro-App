//
//  TimerWidget.swift
//  TimerWidget
//
//  Created by Chris Quagliani on 11/21/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerWidgetView : View {
    let context: ActivityViewContext<TimerAttributes>
    
    var body: some View {
        HStack {
            Text("Pomodoro Timer")
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            Spacer()
            Text(context.state.timeRemaining)
                .font(.system(size: 28))
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
        }
        .padding(.horizontal)
        .padding(.vertical, 25)
        .activityBackgroundTint(Color.black.opacity(0.5))
    }
}

struct TimerWidget: Widget {
    let kind: String = "TimerWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            TimerWidgetView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {

                }
                DynamicIslandExpandedRegion(.trailing) {

                }
                DynamicIslandExpandedRegion(.center) {

                }
                DynamicIslandExpandedRegion(.bottom) {

                }
            } compactLeading: {
                
            } compactTrailing: {
               
            } minimal: {

            }
        }
    }
}
