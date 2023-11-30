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
                Text("\(context.state.timerType) Timer")
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
            .activityBackgroundTint(Color.black.opacity(0.6))
            
            ProgressBar(progress: context.state.progress, nextRoundEmoji: context.state.timerType == "Focus" ? "☕️" : "📚")
                .padding(.bottom, 20)
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

struct ProgressBar: View {
    var progress: Float
    var nextRoundEmoji: String

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    Rectangle() // Static progress bar
                        .frame(height: 15)
                        .opacity(0.3)
                        .cornerRadius(20)
                    
                    Rectangle() // Active progress fill
                        .frame(width: geometry.size.width * CGFloat(progress), height: 15)
                        .foregroundColor(.white)
                        .animation(.linear, value: progress)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Text(nextRoundEmoji)
                    .font(.system(size: 25))
            }
        }
    }
}
