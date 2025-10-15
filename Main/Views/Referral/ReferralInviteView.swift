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
                
                HStack{
                    Image("diversity")
                        .font(.system(size: 100, weight: .thin))
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
                
                HStack{
                    Text("Your friend uses your referral code")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Image("match_word")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                HStack{
                    Image("sentiment")
                        .font(.system(size: 100, weight: .thin))
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
                
                HStack{
                    Text("Your friend gets 1 months of subscription")
                        .font(.title3).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Image("wine")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Spacer()
                
                Button(action: {
                    logger.i("Invite tapped → open share sheet", tag: LOG_TAG)
                    isShareSheetPresented = true
                }) {
                    Text("Invite")
                        .font(.body).bold()
                        .foregroundColor(Color("TextPrimaryFixed"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Accent"))
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color("Border"), lineWidth: 2)
                )
                .compositingGroup()
                .sheet(isPresented: $isShareSheetPresented) {
                    ActivityViewController(activityItems: [inviteMessage])
                }
            }
            .padding(40)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
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
