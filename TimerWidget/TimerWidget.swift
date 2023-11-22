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
        VStack {
            HStack {
                Text("Pomodoro Timer")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundColor(.white).opacity(0.6)
                
                Spacer()
            }
            .padding(.bottom, 5)

            Text(context.state.timeRemaining)
                .font(.system(size: 22))
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
        }
        .padding()
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
