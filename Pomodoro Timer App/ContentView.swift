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
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            TimerView()
        }
    }

}

#Preview {
    ContentView()
}
