//
//  EmojiGridView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI

struct EmojiGridView: View {
    @Binding var colorMode: AppColorMode
    let emojis: [String]
    @Binding var emojiSelection: String
    @Binding var showingFocusEmojiGrid: Bool
    @Binding var showingBreakEmojiGrid: Bool
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
        let roundType = showingFocusEmojiGrid == true ? "Focus" : "Break"
        
        ZStack {
            Color.theme.primaryColor.edgesIgnoringSafeArea(.all)
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: {
                                emojiSelection = emoji
                            }) {
                                Text(emoji)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(emojiSelection == emoji ? Color.gray.opacity(0.5) : Color.clear)
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
        .modifier(ColorModeViewModifier(mode: colorMode))
    }
}
