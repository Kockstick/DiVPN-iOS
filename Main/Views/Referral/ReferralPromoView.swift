//
//  ReferralPromoView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

struct ReferralPromoView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let LOG_TAG = "ReferralPromoView"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 50)
                
                Image("AddFriend")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                    .frame(maxHeight: 40)
                
                Text("Invite friends and get free subscription months")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                
                Spacer()
                
                DrawButton(title: "Learn more", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                    logger.i("Learn more tapped", tag: LOG_TAG)
                    ReferralManager.shared.showReferralInviteInMain = true
                    DispatchQueue.main.async {
                        logger.i("Dismissing ReferralPromoView after Learn more", tag: LOG_TAG)
                        dismiss()
                    }
                }
            }
            .padding(40)
            .padding(.bottom, 10)
            .padding(.top, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onAppear(perform: {
            ReferralManager.shared.isReferralPromoShowed = true
            logger.i("ReferralPromoView appeared", tag: LOG_TAG)
        })
        .overlay(alignment: .topLeading) {
            Button(action: {
                logger.i("Back tapped → dismiss()", tag: LOG_TAG)
                dismiss()
            }) {
                HStack (spacing: 0){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 16, height: 16)
                        .contentShape(Circle())
                    Text("back")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
        }
    }
}
