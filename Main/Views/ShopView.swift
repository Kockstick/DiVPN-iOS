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
    @StateObject var agreementManager = AgreementManager.shared
    @EnvironmentObject var tariffManager: TariffManager
    
    @Environment(\.colorScheme) var colorScheme
    
    private let LOG_TAG = "ShopView"
    private let logger = DiLogger.shared
    
    var body: some View {
        VStack(spacing: 0){
            Image("paid")
                .font(.system(size: 180, weight: .light))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
                .frame(maxHeight: 15)
            
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
            
            Spacer()
                .frame(maxHeight: 30)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 30)
            
            Text(tariffManager.daysToEntTariff ?? 1 > 0 ?
                 "Free trial ends in \(tariffManager.daysToEntTariffText) days" :
                    tariffManager.isFreeTrial ? "Free trial has ended" : "Subscribtion has ended")
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineSpacing(6)
            .shimmer(tariffManager.tariff == nil)
            
            Spacer()
            
            PurchasePanel(showPrice: false)
        }
        .padding(.horizontal, 40)
        .padding(.top, 70)
        .padding(.bottom, 50)
    }
}
