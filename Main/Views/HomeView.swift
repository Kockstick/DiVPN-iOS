//
//  HomeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    
    @StateObject var viewModel = HomeViewModel()
    @StateObject var statusModel = DiStatus.shared
    @EnvironmentObject var tariffManager: TariffManager
    
    var body: some View {
        ZStack {
            VStack{
                DiHeader(title: "DiVPN",
                         subtitle: tariffManager.tariff?.name ?? "...",
                         isAnimated: statusModel.loading || tariffManager.tariff == nil)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 2
                    }
                    
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                Spacer()
                ZStack{
                    ZStack{
                        Toggle(isOn: $statusModel.isEnabled){
                            EmptyView()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("Accent")))
                        .labelsHidden()
                        .shadow(radius: 3)
                        .contentShape(Rectangle())
                        .onChange(of: statusModel.isEnabled) { newValue in
                            statusModel.isEnabled ? viewModel.startVPN() : viewModel.stopVPN()
                        }
                    }
                    .padding(10)
                    .padding(.trailing, 2)
                    .onTapGesture {
                        statusModel.isEnabled = !statusModel.isEnabled
                    }
                    .scaleEffect(1.8)
                }
                .padding(.leading, -2)
                .disabled(!tariffManager.isActiveTariff)
                .opacity(tariffManager.isActiveTariff ? 1 : 0.5)
                
                
                Spacer()
                
                Text(statusModel.statusText)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 50)
                    .shimmer(statusModel.loading, color: Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top,60)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear(){
            viewModel.checkConnection()
        }
    }
}
