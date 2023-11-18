//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        ZStack {
            Color(red: 250/255, green: 249/255, blue: 246/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Pomodoro Timer")
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
