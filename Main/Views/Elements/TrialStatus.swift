//
//  TrialStatus.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 18.01.2026.
//

import SwiftUI

struct TrialStatus: View{
    @ObservedObject var tariffManager: TariffManager
    
    var body: some View{
        Text(tariffManager.daysToEntTariff ?? 1 > 0 ?
             "Free trial ends in \(tariffManager.daysToEntTariffText) days" :
                tariffManager.isFreeTrial ? "Free trial has ended" : "Subscribtion has ended")
        .font(.title2).bold()
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineSpacing(6)
        .shimmer(tariffManager.tariff == nil)
    }
}
