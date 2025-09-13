//
//  DiHeader.swift
//  Outline
//
//  Created by Diesperov Konstantin on 13.08.2025.
//

import SwiftUI

struct DiHeader: View {
    let title: String
    let subtitle: String
    let isAnimated: Bool
    
    @State private var gradientX: CGFloat = -1.0
    @State private var alpha: Double = 1.0
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 64, weight: .bold))
                .shimmer(isAnimated)
            
            Rectangle()
                .frame(width: 160, height: 2)
                .shimmer(isAnimated)
            
            Text(subtitle)
                .font(.system(size: 32, weight: .bold))
                .shimmer(isAnimated)
        }
    }
}
