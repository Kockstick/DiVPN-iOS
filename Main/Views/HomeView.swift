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
                Spacer()
                    .frame(maxHeight: 30)
                ZStack{
                    Image("ClickHere")
                        .resizable()
                        .frame(maxWidth: 230, maxHeight: 230)
                        .foregroundStyle(
                            Color("TextSecondary")
                        )
                        .opacity(DiStatus.shared.connected ? 0 : 1)
                    
                    Image("YouAreProtected")
                        .resizable()
                        .frame(maxWidth: 180, maxHeight: 180)
                        .foregroundStyle(
                            Color("TextSecondary")
                        )
                        .opacity(DiStatus.shared.connected ? 1 : 0)
                        .padding(.bottom, 40)
                }
                .animation(.smooth(duration: 1), value: DiStatus.shared.connected)
                
                Spacer()
                    .frame(maxHeight: 70)
                
                ZStack{
                    ZStack{
                        Toggle(isOn: $statusModel.isEnabled){
                            EmptyView()
                        }
                        .toggleStyle(ToggleDraw())
                        .labelsHidden()
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
                }
                .padding(.leading, -2)
                .disabled(!tariffManager.isActiveTariff || statusModel.loading && statusModel.connected)
                .opacity(tariffManager.isActiveTariff ? 1 : 0.5)
                
                
                Spacer()
                
                Text(statusModel.statusText)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 50)
                    .shimmer(statusModel.loading, color: Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top,120)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear(){
            viewModel.checkConnection()
        }
        .background {
            Image("Background")
                .resizable()
                .scaledToFill()
                .foregroundStyle(
                    Color(statusModel.connected ? "ActiveBackground" : "Background")
                )
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.5), value: statusModel.connected)
        }
    }
}
