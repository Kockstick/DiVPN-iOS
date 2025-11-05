//
//  HomeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @StateObject var statusModel = DiStatus.shared
    @EnvironmentObject var tariffManager: TariffManager
    
    @StateObject var animator = ArrowLoader(22)
    
    var body: some View {
        ZStack {
            VStack{
                if let img = animator.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 250, height: 355)
                        .foregroundColor(Color("TextPrimary"))
                }
                
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
                            statusModel.isEnabled ? animator.play() : animator.stop()
                        }
                    }
                    .padding(.top, -20)
                    .padding(.horizontal, 10)
                    .padding(.trailing, 2)
                    .onTapGesture {
                        statusModel.isEnabled = !statusModel.isEnabled
                    }
                }
                .padding(.leading, -2)
                .disabled(!tariffManager.isActiveTariff || statusModel.loading && statusModel.connected)
                .opacity(tariffManager.isActiveTariff ? 1 : 0.5)
                
                
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
                    Color(statusModel.connected ? "ActiveBackground" : "Background")
                )
                .ignoresSafeArea()
                .animation(.smooth(duration: 0.5), value: statusModel.connected)
                .background(Color("DarkBackground"))
        }
    }
}
