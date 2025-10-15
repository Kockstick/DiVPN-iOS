//
//  OptionsView.swift
//  Outline
//
//

import SwiftUI

struct OptionsView: View {
    private let haptic = UINotificationFeedbackGenerator()
    @StateObject var vm = OptionsViewModel()
    @StateObject var ssManager = ShadowsocksManager.shared
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthState
    @EnvironmentObject var referralModel: ReferralManager
    
    @State private var showConfirmLogout = false
    @State private var showPromoView = false
    @State private var showBugReport = false
    @State private var showSupportView = false
    @State private var bugReportSent = false
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    Text(ssManager.serverLocation ?? "• • • • • •")
                        .font(.largeTitle).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .shimmer(ssManager.serverLocation == nil, color: Color("TextSecondary"))
                        .overlay(alignment: .trailing){ }
                    
                    Spacer()
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action: {
                        referralModel.showReferralInviteInMain = true
                    }) {
                        HStack(spacing: 20){
                            Image("diversity")
                                .font(.system(size: 45, weight: .thin))
                                .frame(width: 45, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Referral")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action: {
                        showPromoView = true
                    }) {
                        HStack(spacing: 20){
                            Image("local_activity")
                                .font(.system(size: 45, weight: .thin))
                                .frame(width: 45, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Promocode")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showPromoView) {
                        PromocodeView()
                    }
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action: {
                        referralModel.showReferralInviteInMain = true
                    }) {
                        HStack(spacing: 20){
                            Image("star")
                                .font(.system(size: 55, weight: .thin))
                                .frame(width: 45, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Rate us")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action:  {
                        showSupportView = true
                    }) {
                        HStack(spacing: 20){
                            Image("support")
                                .font(.system(size: 45, weight: .thin))
                                .frame(width: 45, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Support")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showSupportView) {
                        SupportView()
                    }
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button(action: {
                        showBugReport = true
                    }) {
                        HStack(spacing: 20){
                            if bugReportSent{
                                Image("check")
                                    .font(.system(size: 45, weight: .thin))
                                    .frame(width: 45, height: 35)
                                    .foregroundColor(Color("Active"))
                                Text("Report sent successfully")
                                    .font(.body).bold()
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Image("bug")
                                    .font(.system(size: 45, weight: .thin))
                                    .frame(width: 45, height: 35)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Report a problem")
                                    .font(.body).bold()
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showBugReport) {
                        ReportView(bugReportSent: $bugReportSent)
                    }
                    .disabled(bugReportSent)
                    
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
                            case .failure(let error):
                                haptic.notificationOccurred(.error)
                            }
                        }
                    }) {
                        HStack(spacing: 20){
                            ZStack{
                                Image("swap_horiz")
                                    .font(.system(size: 45, weight: .thin))
                                    .frame(width: 45, height: 35)
                                    .foregroundColor(Color("TextPrimary"))
                                    .opacity(ssManager.isWaitSsKey ? 0 : 1)
                                CircleLoader(color: Color("TextPrimary"))
                                    .opacity(ssManager.isWaitSsKey ? 1 : 0)
                            }
                            
                            Text("Change server")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(ssManager.isWaitSsKey)
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Button (action:  {
                        showConfirmLogout = true
                    }) {
                        HStack(spacing: 20){
                            Image("logout")
                                .font(.system(size: 45, weight: .thin))
                                .frame(width: 45, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Logout")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .confirmationDialog("Are you shure?", isPresented: $showConfirmLogout) {
                        Button("Logout", role: .destructive) {
                            vm.logout() { result in
                                auth.isAuthorized = false
                            }
                        }
                        Button("Cansel", role: .cancel) {}
                    }
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(0.2)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(40)
            .padding(.bottom, 0)
            .onAppear { haptic.prepare() }
        }
    }
}
