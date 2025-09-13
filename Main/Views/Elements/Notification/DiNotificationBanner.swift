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
                        .frame(maxHeight: 10)
                    
                    Image("update")
                        .font(.system(size: 160, weight: .thin))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    Text("Time to update")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    Text("We fixed bugs, polished the UI, and added a couple of handy extras. No magic, just an update.")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("TextSecondary"))
                        .lineSpacing(12)
                    
                    Spacer()
                    
                    Button(action: {
                        logger.i("Open App Store tapped", tag: LOG_TAG)
                    }) {
                        Text("Open App Store")
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
                .background(Color("Surface"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(40)
        }
        .background(Color("Surface"))
        .frame(maxWidth: show ? .infinity : nil, maxHeight: show ? .infinity : nil)
        .opacity(show ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: show)
        .onAppear { logger.i("Banner appeared (show=\(show))", tag: LOG_TAG) }
        .onDisappear { logger.i("Banner disappeared", tag: LOG_TAG) }
        .onChange(of: show) { newValue in
            logger.i("Banner visibility changed: \(newValue)", tag: LOG_TAG)
        }
    }
}
