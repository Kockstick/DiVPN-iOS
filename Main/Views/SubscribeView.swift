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
                        
                        Image("check")
                            .font(.system(size: 180, weight: .light))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 10)
                        
                        Text("\(String(describing: tariffManager.tariffName)) is active")
                            .font(.largeTitle).bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 30)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
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
                            HStack{
                                Image("error")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(Color("Error"))
                                Text("Your subscription ends in \(tariffManager.daysToEntTariffText) days.")
                                    .font(.title2).bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .shimmer(tariffManager.tariff == nil, color: Color("TextPrimary"))
                            }
                        } else {
                            if tariffManager.subscribtionStatus == StatusSubscribtion.active{
                                Text("Subscribtions renews in \(tariffManager.daysToEntTariffText) days")
                                    .font(.title2).bold()
                                    .frame(maxWidth: .infinity, alignment: tariffManager.isActiveTariff ? .center : .leading)
                                    .multilineTextAlignment(tariffManager.isActiveTariff ? .center : .leading)
                                    .lineSpacing(12)
                                    .shimmer(tariffManager.tariff == nil, color: Color("TextSecondary"))
                            } else{
                                HStack{
                                    Image("error")
                                        .font(.system(size: 40, weight: .medium))
                                        .foregroundColor(Color("Error"))
                                    Text("Your subscription ends in \(tariffManager.daysToEntTariffText) days.")
                                        .font(.title2).bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .shimmer(tariffManager.tariff == nil, color: Color("TextPrimary"))
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if tariffManager.subscribtionStatus == StatusSubscribtion.active {
                            Button(action: {
                                showUnsubscribeView = true;
                            }) {
                                if loading{
                                    CircleLoader(color: Color("TextPrimary"))
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                } else {
                                    Text("Do not renew")
                                        .font(.body).bold()
                                        .foregroundColor(Color("TextPrimary"))
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Surface"))
                                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("Border"), lineWidth: 2)
                            )
                            .sheet(isPresented: $showUnsubscribeView){
                                UnsubscribeView(loading: $loading)
                            }
                        } else if tariffManager.subscribtionStatus == StatusSubscribtion.trial {
                            PurchasePanel(showPrice: true)
                        } else{
                            Button(action: {
                                loading = true
                                invoiceApi.resumeSubscribtion() { res in
                                    TariffManager.shared.loadTariff() {_ in
                                        loading = false
                                    }
                                }
                                haptic.notificationOccurred(.warning)
                            }) {
                                if loading{
                                    CircleLoader(color: Color("TextPrimaryFixed"))
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                } else {
                                    Text("Resume subscription")
                                        .font(.body).bold()
                                        .foregroundColor(Color("TextPrimaryFixed"))
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                }
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
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 70)
            .padding(.bottom, 50)
            .onAppear { haptic.prepare() }
            .overlay(alignment: .topTrailing) {
                if tariffManager.subscribtionStatus == StatusSubscribtion.active {
                    Button(action: {
                        showChangeCardView = true
                    }) {
                        Image("payment_card")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(width: 32, height: 32)
                            .contentShape(Circle())
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
            }
        }
    }
}
