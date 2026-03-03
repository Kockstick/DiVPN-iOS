//
//  UpNote.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import SwiftUI

struct UpNote: View {
    var text: String
    var textColor: Color
    var borderColor: Color
    
    var isFocused: Bool
    
    var body: some View {
        ZStack{
            Text(text)
                .font(.footnote)
                .bold()
                .foregroundStyle(textColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 999)
                        .fill(borderColor)
                )
                .animation(.easeInOut(duration: 0.18), value: isFocused)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 15)
        .padding(.bottom, -15)
        .zIndex(1)
    }
}
