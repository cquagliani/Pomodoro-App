//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    @State private var rounds = 4 // Default
    @State private var focusMinutes = 25  // Default
    @State private var breakMinutes = 5   // Default

    var body: some View {
        ZStack {
            Color(red: 237/255, green: 238/255, blue: 240/255, opacity: 1.0).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text("Pomodoro Timer")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 25)

                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 25)
                }
                TimerView(rounds: rounds, focusMinutes: focusMinutes, breakMinutes: breakMinutes)

            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(rounds: $rounds, focusMinutes: $focusMinutes, breakMinutes: $breakMinutes)
        }
    }
}


#Preview {
    ContentView()
}
