//
//  SubscribeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

struct SubscribeView: View {
    @StateObject var tariffManager = TariffManager.shared
    
    var body: some View {
        if tariffManager.isFreeTrial {
            ShopView()
        } else {
            ZStack{
                ZStack{
                    VStack{
                        Spacer()
                            .frame(maxHeight: 20)
                        
                        Image(tariffManager.isActiveTariff ? "check" : "error")
                            .font(.system(size: 180, weight: .thin))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 10)
                        
                        Text("\(String(describing: tariffManager.tariffName)) \(tariffManager.isActiveTariff ? "is active" : "is inactive")")
                            .font(.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                            .frame(maxHeight: 40)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                            .frame(maxHeight: 40)
                        
                        Text(tariffManager.isActiveTariff ? "Subscribtions renews in \(tariffManager.daysToEntTariffText) days" : "To keep using the VPN, please renew your subscription")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: tariffManager.isActiveTariff ? .center : .leading)
                            .multilineTextAlignment(tariffManager.isActiveTariff ? .center : .leading)
                            .lineSpacing(12)
                            .shimmer(tariffManager.tariff == nil, color: Color("TextSecondary"))
                        
                        Spacer()
                        
                        if tariffManager.isActiveTariff {
                            Button(action: {
                                
                                
                            }) {
                                Text("Do not renew")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, maxHeight: 55)
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
                            .compositingGroup()
                        } else {
                            Button(action: {
                                
                                
                            }) {
                                Text("Renew")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimaryFixed"))
                                    .frame(maxWidth: .infinity, maxHeight: 55)
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
                            .compositingGroup()
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 70)
            .padding(.bottom, 50)
        }
    }
}
