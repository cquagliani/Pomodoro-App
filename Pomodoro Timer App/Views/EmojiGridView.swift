//
//  EmojiGridView.swift
//  Pomodoro Timer App
//
//  Created by Chris Quagliani on 12/9/23.
//

import SwiftUI

struct EmojiGridView: View {
    @Binding var colorMode: AppColorMode
    let title: String
    let emojis: [String]
    @Binding var emojiSelection: String
    @Binding var isPresented: Bool
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
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
                .navigationBarTitle(Text(title), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                }
            }
        }
        .modifier(ColorModeViewModifier(mode: colorMode))
    }
}
