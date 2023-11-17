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
            Color(red: 237/255, green: 238/255, blue: 240/255, opacity: 1.0).edgesIgnoringSafeArea(.all)
            VStack {

                HStack {
                    Text("Pomodoro Timer")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 25)
                    Button(action: {
                                print("Navigate to settings")
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 25)
                }
                TimerView()
            }
        }
    }
}

#Preview {
    ContentView()
}
