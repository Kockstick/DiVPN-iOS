//
//  HomeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI

struct HomeView: View {
    private let haptic = UINotificationFeedbackGenerator()
    @StateObject var viewModel = HomeViewModel()
    @StateObject var statusModel = DiStatus.shared
    @EnvironmentObject var tariffManager: TariffManager
    @StateObject var ssManager = ShadowsocksManager.shared
    
    var body: some View {
        ZStack {
            VStack{
                ZStack{
                    ZStack{
                        MetalViewRepresentable()
                            .frame(maxWidth: 450, maxHeight: 450)
                            .padding(.bottom, 0)
                        Image("pug_sad")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 200, maxHeight: 250)
                        Image(statusModel.isEnabled ? "pug_smile" : "pug_sad")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 200, maxHeight: 250)
                            .onTapGesture {
                                statusModel.isEnabled = !statusModel.isEnabled
                                statusModel.isEnabled ? viewModel.startVPN() : viewModel.stopVPN()
                            }
                    }
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        statusModel.isEnabled = !statusModel.isEnabled
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, -50)
                .disabled(!tariffManager.isActiveTariff || statusModel.loading && statusModel.connected)
                .opacity(tariffManager.isActiveTariff ? 1 : 0.5)
                
                VStack{
                    Text(statusModel.connected ? statusModel.connectedTimeText : statusModel.statusText)
                        .font(.body).bold()
                        .foregroundStyle(Color("TextSecondary"))
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action: {
                        ssManager.changeKey() {result in
                            switch result{
                            case .success(let res):
                                if res{
                                    haptic.notificationOccurred(.success)
                                } else{
                                    haptic.notificationOccurred(.warning)
                                }
                            case .failure(_):
                                haptic.notificationOccurred(.error)
                            }
                        }
                    }) {
                        HStack(spacing: 20){
                            ZStack{
                                Image("Swap")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(Color("TextPrimary"))
                                    .opacity(ssManager.isWaitSsKey ? 0 : 1)
                                CircleLoader(color: Color("TextPrimary"))
                                    .opacity(ssManager.isWaitSsKey ? 1 : 0)
                            }
                            
                            Text(ssManager.serverLocation ?? "• • • • • •")
                                .font(.title).bold()
                                .shimmer(ssManager.serverLocation == nil, color: Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(ssManager.isWaitSsKey)
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                }
                .padding(.horizontal, 40)
                  
                Spacer()
                
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
                        .padding(.vertical, 15)
                    }
                    .opacity(DiNotification.shared.showRow ? 1 : 0)
                    .background(DiNotification.shared.rowType.color.opacity(DiNotification.shared.showRow ? 1 : 0))
                }
                .padding(.bottom, 120)
                .clipped()
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: DiNotification.shared.showRow ? nil : 0)
                .zIndex(-1)
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
                    Color("Background")
                )
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.5), value: statusModel.connected)
                .background(Color("DarkBackground"))
        }
        .onAppear { haptic.prepare() }
    }
}
