//
//  PageSelector.swift
//  Outline
//
//  Created by Diesperov Konstantin on 02.11.2025.
//

import SwiftUI

struct PageSelector: View {
    
    @Binding var showLeft: Bool
    @Binding var showRight: Bool
    var SelectedSize: CGFloat = 30
    var DefaultSize: CGFloat = 25
    
    var body: some View {
        VStack{
            Spacer()
            HStack(spacing: 40){
                Button(action: {
                    showRight = false
                    showLeft = true
                }){
                    Image("Build")
                        .resizable()
                        .foregroundColor(Color(showLeft ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
                
                Button(action: {
                    showLeft = false
                    showRight = false
                }){
                    Image("Home")
                        .resizable()
                        .foregroundColor(Color(!showLeft && !showRight ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
                
                Button(action: {
                    showLeft = false
                    showRight = true
                }){
                    Image("PaidBold")
                        .resizable()
                        .foregroundColor(Color(showRight ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
            }
            .frame(alignment: .bottom)
            .padding(.bottom, 5)
        }
    }
}

enum Page {
    case options
    case home
    case subscribe
}
