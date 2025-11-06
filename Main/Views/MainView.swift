//
//  MainView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 07.08.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var auth: AuthState
    @EnvironmentObject var tariffManager: TariffManager
    @EnvironmentObject var referralModel: ReferralManager
    
    @StateObject var viewModel = MainViewModel()
    @StateObject var statusModel = DiStatus.shared
    
    @State private var showLeft = false
    @State private var showRight = false
    
    @State private var greenBackground: Bool = true
    @State private var showUpdateBanner = false
    
    var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(DiNotification.shared.rowType.color)
                    .opacity(DiNotification.shared.showRow ? 1 : 0)
                
                VStack(spacing: 0){
                    SwipePanels(
                                showLeft: $showLeft,
                                showRight: $showRight
                            ) {
                                HomeView()
                            } left: {
                                OptionsView()
                            } right: {
                                SubscribeView()
                            }
                    

                }
                .sheet(isPresented: $referralModel.showReferralPromo) {
                    ReferralPromoView()
                }
                
                PageSelector(showLeft: $showLeft, showRight: $showRight)
                
                DiNotificationBanner(show: showUpdateBanner)
            }
            .animation(.smooth(duration: 0.5), value: greenBackground)
            .animation(.smooth(duration: 0.5), value: statusModel.connected)
            .animation(.spring(duration: 0.2), value: DiNotification.shared.showRow)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear{
                viewModel.checkVerification(){ result in
                    auth.isAuthorized = result
                }
                tariffManager.loadTariff { result in
                    DispatchQueue.main.async {
                        switch result{
                        case .success(let tariff):
                            referralModel.showReferralPromo = tariffManager.daysToEntTariff ?? 0 <= 0 || !referralModel.isReferralPromoShowed
                            print("Current tariff: \(tariff.name)")
                            break
                        case .failure(let error):
                            print("Loading tariff error: \(error)")
                            break
                        }
                    }
                }
                viewModel.checkUpdate() { result in
                    self.showUpdateBanner = result
                }
            }
            .navigationTitle("MainView")
            .sheet(isPresented: $referralModel.showReferralInviteInMain){
                ReferralInviteView()
            }
            .background(Color("DarkBackground"))
    }
}
