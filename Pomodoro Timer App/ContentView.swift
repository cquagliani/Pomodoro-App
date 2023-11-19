//
//  ContentView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 11/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var colorMode: AppColorMode = .dark
    
    var primaryColorLight: Color = Color(red: 250/255, green: 249/255, blue: 246/255)
    var primaryColorDark: Color = Color(red: 44/255, green: 51/255, blue: 51/255)
    
    var body: some View {
        let primaryColor: Color = (colorMode == .dark) ? primaryColorDark : primaryColorLight
        
        ZStack {
            primaryColor.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Pomodoro Timer")
                    .foregroundColor(colorMode == .dark ? primaryColorLight : primaryColorDark)
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
                        Image(systemName: "moon.stars")
                            .foregroundColor(colorMode == .dark ? primaryColorLight : primaryColorDark)
                            .imageScale(.medium)
                            .font(.system(size: 30))
                    }
                    .padding(.horizontal, 20)
                }
                TimerView()
            }
            .modifier(ColorModeViewModifier(mode: colorMode))
        }
    }
    
    private func toggleColorMode() {
        colorMode = (colorMode == .light) ? .dark : .light
    }
}

#Preview {
    ContentView()
}
