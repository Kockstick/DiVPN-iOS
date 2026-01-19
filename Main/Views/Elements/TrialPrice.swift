//
//  TrialPrice.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 18.01.2026.
//

import SwiftUI

struct TrialPrice: View{
    @ObservedObject var tariffManager: TariffManager
    
    var body: some View{
        VStack{
            Text("Subscribe")
                .font(.largeTitle).bold()
                .foregroundColor(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                Text(tariffManager.subscribtionPriceText)
                    .font(.system(size: 48, weight: .bold))
                    .frame(alignment: .leading)
                    .shimmer(tariffManager.subscribtionPrice == nil)
                Text("for 1 month")
                    .font(.largeTitle).bold()
                    .foregroundColor(Color("TextPrimary"))
                    .frame(alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
