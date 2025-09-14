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
    
    @StateObject var viewModel = MainViewModel()
    @StateObject var statusModel = DiStatus.shared
    @StateObject var referralModel = ReferralManager.shared
    
    @State private var selection = 1
    @State private var greenBackground: Bool = true
    @State private var isKeyboardShown = false
    @State private var showUpdateBanner = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(DiNotification.shared.rowType.color)
                .opacity(DiNotification.shared.showRow ? 1 : 0)
            
            VStack(spacing: 0){
                TabView(selection: $selection) {
                    OptionsView()
                        .tag(0)
                    HomeView(selectedTab: $selection)
                        .tag(1)
                    SubscribeView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: isKeyboardShown ? .never : .always))
                .highPriorityGesture(
                    DragGesture(),
                    including: isKeyboardShown ? .gesture : .none
                )
                .padding(.bottom, 10)
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("TextPrimary"))
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color("TextSecondary"))
                }
                .background(Color(greenBackground ? statusModel.connected ? "ActiveBackground" : "Background" : "Background"))
                .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                .onChange(of: selection) { newValue in
                    greenBackground = newValue == 1
                }
                
                ZStack{
                    VStack{
                        HStack{
                            Rectangle()
                                .frame(width: 2)
                                .foregroundColor(DiNotification.shared.rowType.textColor)
                            Text(DiNotification.shared.rowText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DiNotification.shared.rowType.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 15)
                    }
                    .opacity(DiNotification.shared.showRow ? 1 : 0)
                }
                .clipped()
                .background(DiNotification.shared.rowType.color.opacity(DiNotification.shared.showRow ? 1 : 0))
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: DiNotification.shared.showRow ? nil : 0)
                .zIndex(-1)
            }
            .sheet(isPresented: $referralModel.showReferralPromo) {
                ReferralPromoView()
            }
            
            DiNotificationBanner(show: showUpdateBanner)
        }
        .background(Color(greenBackground ? statusModel.connected ? "ActiveBackground" : "Background" : "Background"))
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
                        referralModel.showReferralPromo = tariffManager.daysToEntTariff == 0 || !referralModel.isReferralPromoShowed
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
            ShadowsocksManager.shared.updateKey()
        }
        .navigationTitle("MainView")
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardShown = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardShown = false
        }
    }
}
