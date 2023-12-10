//
//  EmojiGridView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI

struct EmojiGridView: View {
    let emojis: [String]
    @Binding var selection: String
    @Binding var showingFocusEmojiGrid: Bool
    @Binding var showingBreakEmojiGrid: Bool
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
        let roundType = showingFocusEmojiGrid == true ? "Focus" : "Break"
        
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            self.selection = emoji
                        }) {
                            Text(emoji)
                                .font(.title)
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(self.selection == emoji ? Color.gray.opacity(0.5) : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text("Select \(roundType) Emoji"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFocusEmojiGrid = false
                        showingBreakEmojiGrid = false
                    }
                    .foregroundColor(Color/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding()
                }
            }
        }
    }
}
