//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings: Bool = false
    
    // Default values in settings
    @State private var rounds: Int = 4
    @State private var focusMinutes: Int = 25
    @State private var breakMinutes: Int = 5

    var body: some View {
        ZStack {
            Color(red: 237/255, green: 238/255, blue: 240/255, opacity: 1.0).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
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
                    Spacer()
                }
                TimerView()

            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(showingSettings: $showingSettings, rounds: $rounds, focusMinutes: $focusMinutes, breakMinutes: $breakMinutes)
        }
    }
}


#Preview {
    ContentView()
}
