//
//  CircleLoader.swift
//  Outline
//
//  Created by Diesperov Konstantin on 06.10.2025.
//

import SwiftUI

struct CircleLoader: View {
    @State private var rotation: Angle = .degrees(0)
    @State var color: Color
    @State var size: CGFloat = 25
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
            }
    }
}
