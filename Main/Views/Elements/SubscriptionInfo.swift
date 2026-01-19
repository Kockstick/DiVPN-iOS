//
//  SubscriptionInfo.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 18.01.2026.
//

import SwiftUI

struct SubscriptionInfo: View{
    @StateObject var tariffManager = TariffManager.shared
    
    var body: some View{
        if tariffManager.subscribtionStatus == StatusSubscribtion.cancelled{
            HStack{
                Text(tariffManager.subscribtionPriceText)
                    .font(.largeTitle).bold()
                    .frame(alignment: .leading)
                    .shimmer(tariffManager.subscribtionPrice == nil)
                Text("for 1 month")
                    .font(.title).bold()
                    .foregroundColor(Color("TextPrimary"))
                    .frame(alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            
            EndSubscriptionPanel(tariffManager: tariffManager)
        } else {
            if tariffManager.subscribtionStatus == .active{
                Text("Subscriptions renews in \(tariffManager.daysToEntTariffText) days")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .lineSpacing(12)
                    .shimmer(tariffManager.tariff == nil, color: Color("TextSecondary"))
            } else if tariffManager.subscribtionStatus == .pastDue{
                Text("Subscription renewal")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .lineSpacing(12)
                    .shimmer(tariffManager.tariff == nil, color: Color("TextSecondary"))
            } else{
                EndSubscriptionPanel(tariffManager: tariffManager)
            }
        }
    }
}
