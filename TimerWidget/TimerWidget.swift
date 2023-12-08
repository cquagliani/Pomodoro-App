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
            
            ProgressBar(progress: context.state.progress, nextRoundEmoji: calculateEmoji(context: context))
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
                    Text("\(context.state.timerType) Timer")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.leading, 3)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.timeRemaining)
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .padding(.trailing, 3)
                }
                DynamicIslandExpandedRegion(.center) {

                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressBar(progress: context.state.progress, nextRoundEmoji: calculateEmoji(context: context))
                        .padding(.bottom, 20)
                }
            } compactLeading: {
                Text(context.state.timerType == "Focus" ? "📚" : "☕️")
                    .font(.system(size: 14))
            } compactTrailing: {
                Text(context.state.timeRemaining)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
            } minimal: {
                Text(context.state.timeRemaining)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
            }
        }
    }
}

struct ProgressBar: View {
    var progress: Float
    var nextRoundEmoji: String

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                // Static progress bar background
                Rectangle()
                    .frame(height: 20)
                    .opacity(0.3)
                    .cornerRadius(20)

                // Active progress fill
                Rectangle()
                    .frame(width: max(geometry.size.width * CGFloat(progress), 30), height: 20)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .overlay(
                        Text(nextRoundEmoji)
                            .font(.system(size: 15))
                            .background(Color.white)
                            .padding(5)
                            .cornerRadius(20),
                        alignment: .trailing
                    )
                    .animation(.linear, value: progress)
            }
        }
    }
}

fileprivate func calculateEmoji(context: ActivityViewContext<TimerAttributes>) -> String {
    let calculateEmoji: String
    
    if context.state.completedBreaks < 3 {
        calculateEmoji = context.state.timerType == "Focus" ? "📚" : "☕️"
    } else {
        calculateEmoji = context.state.completedRounds == 4 ? "🎉" : "🏆"
    }
    
    return calculateEmoji
}


//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//    
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//extension View {
//    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners) )
//    }
//}
