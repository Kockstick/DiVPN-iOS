//
//  DiNotificationBanner.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.08.2025.
//

import SwiftUI

struct DiNotificationBanner: View{
    @Environment(\.colorScheme) var colorScheme
    public static var shared = DiNotificationBanner()
    var show: Bool = false
    
    private let LOG_TAG: String = "DiNotificationBanner"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                        .frame(maxHeight: 25)
                    
                    Image("Update")
                        .resizable()
                        .frame(width: 180, height: 180)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 30)
                    
                    Text("Time to update")
                        .font(.largeTitle).bold()
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    Image("Divider")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    Text("We fixed bugs, polished the UI, and added a couple of handy extras. No magic, just an update.")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("TextSecondary"))
                        .lineSpacing(12)
                    
                    Spacer()
                    
                    DrawButton(title: "Open App Store", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                        logger.i("Open App Store tapped", tag: LOG_TAG)
                        openDiVPNInAppStore()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(40)
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
        .frame(maxWidth: show ? .infinity : nil, maxHeight: show ? .infinity : nil)
        .opacity(show ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: show)
        .onAppear { logger.i("Banner appeared (show=\(show))", tag: LOG_TAG) }
        .onDisappear { logger.i("Banner disappeared", tag: LOG_TAG) }
        .onChange(of: show) { newValue in
            logger.i("Banner visibility changed: \(newValue)", tag: LOG_TAG)
        }
    }
    
    private func openDiVPNInAppStore() {
        let appID = "6754507149"
        let itmsURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)")!
        let webURL  = URL(string: "https://apps.apple.com/app/id\(appID)")!

        // itms-apps открывает сразу App Store; если вдруг не получится — падаем на https
        if UIApplication.shared.canOpenURL(itmsURL) {
            UIApplication.shared.open(itmsURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
