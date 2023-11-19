//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var colorMode: AppColorMode = .system
    
    var body: some View {
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Pomodoro Timer")
                    .foregroundColor(Color.theme.invertedPrimary)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 25)
                
                Button(action: {
                    toggleColorMode()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: colorMode == .light ? "moon.stars" : "sun.max")
                            .foregroundColor(Color.theme.invertedPrimary)
                            .imageScale(.medium)
                            .font(.system(size: 30))
                    }
                    .padding(.horizontal, 20)
                }
                TimerView()
            }
        }
        .modifier(ColorModeViewModifier(mode: colorMode))
    }
    
    private func toggleColorMode() {
        colorMode = (colorMode == .light) ? .dark : .light
    }
}

#Preview {
    ContentView()
}
