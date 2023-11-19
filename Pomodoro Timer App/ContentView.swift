//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var currentMode
    var primaryColorLight: Color = Color(red: 250/255, green: 249/255, blue: 246/255)
    var primaryColorDark: Color = Color(red: 44/255, green: 51/255, blue: 51/255)
    
    var body: some View {
        let primaryColor: Color = (currentMode == .dark) ? primaryColorDark : primaryColorLight
        
        ZStack {
            primaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Pomodoro Timer")
                    .foregroundColor(currentMode == .dark ? primaryColorLight : primaryColorDark)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 25)
                TimerView()
            }
        }
    }
}

#Preview {
    ContentView()
}
