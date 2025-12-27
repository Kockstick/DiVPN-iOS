//
//  EndSubscriptionPanel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 03.11.2025.
//

import SwiftUI

struct EndSubscriptionPanel: View{
    @StateObject var tariffManager: TariffManager
    
    var body: some View{
        HStack{
            Image("ErrorBold")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("ForceError"))
            Text("Your subscription ends in \(tariffManager.daysToEntTariffText) days.")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .shimmer(tariffManager.tariff == nil, color: Color("TextPrimary"))
        }
    }
}
