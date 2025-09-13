//
//  ShopView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI

struct ShopView : View {
    @StateObject var viewModel = ShopViewModel()
    @StateObject var statusModel = DiStatus.shared
    @EnvironmentObject var tariffManager: TariffManager
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("Subscribe")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Text("99\u{20BD}")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(alignment: .leading)
                    Text("for 1 month")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(maxHeight: 40)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 40)
            
            VStack(spacing: 25){
                Text("Fastest VPN at maximum speed")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(6)
                Text("Unlimited internet access with data protection")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(maxHeight: 40)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 40)
            
            Text(tariffManager.daysToEntTariff ?? 1 > 0 ?
                 "Free trial ends in \(tariffManager.daysToEntTariffText) days" :
                    "Free trial has ended")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(6)
                .shimmer(tariffManager.tariff == nil)
            
            Spacer()
            
            Button(action: {
                
                
            }) {
                Text("Purchase subscription")
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
        .padding(.horizontal, 40)
        .padding(.top, 70)
        .padding(.bottom, 50)
    }
}
