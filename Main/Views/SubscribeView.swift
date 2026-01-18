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
                            .interpolation(.low)
                            .frame(width: 190, height: 180)
                            .foregroundColor(Color("TextPrimary"))
                            .drawingGroup()
                        
                        Spacer()
                            .frame(maxHeight: 30)
                        
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
                            .drawingGroup()
                        
                        Spacer()
                            .frame(maxHeight: 30)
                        
                        SubscriptionInfo()
                        
                        Spacer()
                        
                        SubscriptionOptions(showUnsubscribeView: $showUnsubscribeView, loading: $loading)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 70)
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
                    .disabled(loading || showUnsubscribeView || showChangeCardView)
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
