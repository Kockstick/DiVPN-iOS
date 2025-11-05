//
//  ReferralInviteView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

struct ReferralInviteView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShareSheetPresented = false
    @State private var loading: Bool = false
    
    private let horizontalSpacing: CGFloat = 30
    
    private var inviteMessage: String {
        let code = (DiStorage.loadRefCode() ?? "").unquoted
        return String(format: NSLocalizedString("referral_message", comment: ""), code)
    }
    
    private let LOG_TAG = "ReferralInviteView"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 50)
                
                HStack(spacing: horizontalSpacing){
                    Image("AddFriend")
                        .resizable()
                        .frame(width: 100, height: 90)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Invite friends to DiVPN")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                    .frame(maxHeight: 20)
                
                HStack(spacing: horizontalSpacing){
                    Text("Your friend uses your referral code")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Image("Word")
                        .resizable()
                        .frame(width: 110, height: 95)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Image("Divider")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 6)
                    .foregroundColor(Color("TextSecondary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                HStack(spacing: horizontalSpacing){
                    Image("Smile")
                        .resizable()
                        .frame(width: 100, height: 95)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("You get 1 month of subscription")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                    .frame(maxHeight: 20)
                
                HStack(spacing: horizontalSpacing){
                    Text("Your friend gets 1 months of subscription")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Image("Vine")
                        .resizable()
                        .frame(width: 70, height: 120)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                
                DrawButton(title: "Invite", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: loading){
                    loading = true
                    logger.i("Invite tapped → open share sheet", tag: LOG_TAG)
                    isShareSheetPresented = true
                }
                .sheet(isPresented: $isShareSheetPresented) {
                    ActivityViewController(activityItems: [inviteMessage])
                        .onDisappear(){
                            loading = false
                        }
                }
            }
            .padding(40)
            .padding(.bottom, 10)
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
                        .font(.body)
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
        }
    }
}
