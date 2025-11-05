//
//  RateView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 13.09.2025.
//
//вцу

import SwiftUI

struct RateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    Image("star")
                        .font(.system(size: 230, weight: .thin))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 10)
                    
                    Text("Feedback")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    Text("We’d love to hear from you! Leave a review and we’ll thank you with 1 month of subscription for free.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(12)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        
                    }) {
                        Text("Ok")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("TextPrimaryFixed"))
                            .frame(maxWidth: .infinity, maxHeight: 55)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Accent"))
                            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Border"), lineWidth: 2)
                    )
                    .compositingGroup()
                }
                .padding(40)
                .padding(.bottom, 10)
                .padding(.top, 30)
                .background(
                    GeometryReader { proxy in
                        Image("star_rate")
                            .font(.system(size: 500, weight: .medium))
                            .frame(alignment: .topTrailing)
                            .foregroundColor(Color("TextSecondary"))
                            .opacity(colorScheme == .dark ? 0.04 : 0.07)
                            .offset(x: 110, y: -120)
                    })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
        }
    }
}
