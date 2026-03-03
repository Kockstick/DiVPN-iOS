
//
//  RadioButton.swift
//  Outline
//
//  Created by Diesperov Konstantin on 05.10.2025.
//

import SwiftUI

struct RadioButton: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("TextPrimary"), lineWidth: 2)
                .frame(width: 24, height: 24)
            if isSelected {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
