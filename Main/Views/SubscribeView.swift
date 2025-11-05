//
//  SubscribeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

struct SubscribeView: View {
    @StateObject var tariffManager = TariffManager.shared
    @StateObject var statusModel = DiStatus.shared
    @StateObject var agreementManager = AgreementManager.shared
    
    private let haptic = UINotificationFeedbackGenerator()
    
    private let invoiceApi = InvoiceApi()
    
    @State var showUnsubscribeView = false
    @State var showChangeCardView = false
    @State var loading: Bool = false
    
    var body: some View {
        if tariffManager.isFreeTrial || !tariffManager.isActiveTariff {
            ShopView()
        } else {
            ZStack{
                ZStack{
                    VStack{
                        Spacer()
                            .frame(maxHeight: 20)
                        
                        Image("Check")
                            .resizable()
                            .frame(width: 190, height: 180)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 20)
                        
                        Text("\(String(describing: tariffManager.tariffName)) is active")
                            .font(.largeTitle).bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 30)
                        
                        Image("Divider")
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .frame(height: 6)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                            .frame(maxHeight: 30)
                        
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
                            if tariffManager.subscribtionStatus == StatusSubscribtion.active{
                                Text("Subscribtions renews in \(tariffManager.daysToEntTariffText) days")
                                    .font(.title2).bold()
                                    .frame(maxWidth: .infinity, alignment: tariffManager.isActiveTariff ? .center : .leading)
                                    .multilineTextAlignment(tariffManager.isActiveTariff ? .center : .leading)
                                    .lineSpacing(12)
                                    .shimmer(tariffManager.tariff == nil, color: Color("TextSecondary"))
                            } else{
                                EndSubscriptionPanel(tariffManager: tariffManager)
                            }
                        }
                        
                        Spacer()
                        
                        if tariffManager.subscribtionStatus == StatusSubscribtion.active {
                            DrawButton(title: "Do not renew", bgColor: Color("Surface"), textColor: Color("TextPrimary"), isLoading: loading){
                                showUnsubscribeView = true;
                            }
                            .sheet(isPresented: $showUnsubscribeView){
                                UnsubscribeView(loading: $loading)
                            }
                        } else if tariffManager.subscribtionStatus == StatusSubscribtion.trial {
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
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 70)
            .onAppear { haptic.prepare() }
            .overlay(alignment: .topTrailing) {
                if tariffManager.subscribtionStatus == StatusSubscribtion.active {
                    Button(action: {
                        showChangeCardView = true
                    }) {
                        Image("Card")
                            .resizable()
                            .foregroundColor(Color("TextSecondary"))
                            .frame(width: 40, height: 30)
                            .contentShape(Rectangle())
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 30)
                    .accessibilityLabel("Change Card")
                }
            }
            .sheet(isPresented: $showChangeCardView){
                ChangeCardView()
            }
            .background {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(
                        Color("Background")
                    )
                    .ignoresSafeArea()
                    .background(Color("DarkBackground"))
            }
        }
    }
}
