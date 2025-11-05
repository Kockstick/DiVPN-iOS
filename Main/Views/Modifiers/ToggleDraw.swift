//
//  ToggleDraw.swift
//  Outline
//
//  Created by Diesperov Konstantin on 01.11.2025.
//

import SwiftUI

struct ToggleDraw: ToggleStyle {
    var size: CGSize = .init(width: 120, height: 50)
    var inset: CGFloat = 6
    var onTint: Color = Color("Accent")
    var offTint: Color = Color("Background")

    func makeBody(configuration: Configuration) -> some View {
        let knobSide = size.height * 1.6 - inset * 2

        ZStack {
            // фон
            Image("ToggleBackground")
                .resizable()
                .scaledToFill()
                .frame(height: size.height)
                .foregroundStyle(configuration.isOn ? onTint : offTint)

            // рамка
            Image("ToggleBorder")
                .resizable()
                .scaledToFill()
                .frame(height: size.height)
                .foregroundStyle(Color("TextPrimary"))

            // ползунок
            HStack {
                if configuration.isOn { Spacer() }
                Image("Toggle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: knobSide, height: knobSide)
                    .foregroundStyle(Color("TextPrimary"))
                    .padding(.horizontal, inset)
                if !configuration.isOn { Spacer() }
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(RoundedRectangle(cornerRadius: size.height/2))
        .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                configuration.isOn.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Switch")
        .accessibilityValue(configuration.isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            configuration.isOn.toggle()
        }
    }
}

