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
            Image("Paid")
                .resizable()
                .interpolation(.low)
                .font(.system(size: 180, weight: .light))
                .frame(width: 180, height: 180)
                .foregroundColor(Color("TextPrimary"))
                .drawingGroup()
            
            Spacer()
                .frame(maxHeight: 30)
            
            TrialPrice(tariffManager: tariffManager)
            
            Spacer()
                .frame(maxHeight: 30)
            
            Image("Divider")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 6)
                .foregroundColor(Color("TextSecondary"))
                .drawingGroup()
            
            Spacer()
                .frame(maxHeight: 30)
            
            TrialStatus(tariffManager: tariffManager)
            
            Spacer()
            
            PurchasePanel(showPrice: false)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 70)
        .background {
            ZStack{
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(
                        Color("Background")
                    )
                    .ignoresSafeArea()
            }
            .background(Color("DarkBackground"))
        }
    }
}
