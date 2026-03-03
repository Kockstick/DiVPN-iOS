//
//  PageSelector.swift
//  Outline
//
//  Created by Diesperov Konstantin on 02.11.2025.
//

import SwiftUI

struct PageSelector: View {
    
    @Binding var index: Int
    var SelectedSize: CGFloat = 30
    var DefaultSize: CGFloat = 25
    
    var body: some View {
        VStack{
            Spacer()
            HStack(spacing: 40){
                Button(action: {
                    index = 0
                }){
                    Image("Build")
                        .resizable()
                        .foregroundColor(Color(index == 0 ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
                
                Button(action: {
                    index = 1
                }){
                    Image("Home")
                        .resizable()
                        .foregroundColor(Color(index == 1 ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
                
                Button(action: {
                    index = 2
                }){
                    Image("ManageBold")
                        .resizable()
                        .foregroundColor(Color(index == 2 ? "TextPrimary" : "TextSecondary"))
                        .frame(width: SelectedSize, height: SelectedSize, alignment: .center)
                }
                
                Button(action: {
                    index = 3
                }){
                    Image("PaidBold")
                        .resizable()
                        .foregroundColor(Color(index == 3 ? "TextPrimary" : "TextSecondary"))
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
