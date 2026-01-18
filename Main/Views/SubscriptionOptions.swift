//
//  SubscriptionOptions.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 18.01.2026.
//

import SwiftUI

struct SubscriptionOptions: View{
    @StateObject var tariffManager = TariffManager.shared
    @Binding var showUnsubscribeView: Bool
    @Binding var loading: Bool
    
    private let invoiceApi = InvoiceApi()
    private let haptic = UINotificationFeedbackGenerator()
    
    var body: some View{
        if tariffManager.subscribtionStatus == .active || tariffManager.subscribtionStatus == .pastDue {
            DrawButton(title: "Do not renew", bgColor: Color("Surface"), textColor: Color("TextPrimary"), isLoading: loading){
                showUnsubscribeView = true;
            }
            .sheet(isPresented: $showUnsubscribeView){
                UnsubscribeView(loading: $loading)
            }
        } else if tariffManager.subscribtionStatus == StatusSubscribtion.trialActive {
            PurchasePanel(showPrice: true)
        } else{
            DrawButton(title: "Resume subscription", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: loading){
                loading = true
                invoiceApi.resumeSubscribtion() { res in
                    TariffManager.shared.loadTariff() {_ in
                        loading = false
                    }
                }
                haptic.notificationOccurred(.warning)
            }
            .onAppear { haptic.prepare() }
        }
    }
}
