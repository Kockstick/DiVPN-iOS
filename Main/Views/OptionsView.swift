//
//  OptionsView.swift
//  Outline
//
//

import SwiftUI

struct OptionsView: View {
    @StateObject var vm = OptionsViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthState
    @EnvironmentObject var referralModel: ReferralManager
    
    @State private var showConfirmLogout = false
    @State private var showBugReport = false
    @State private var showSupportView = false
    @State private var bugReportSent = false
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    Image("build")
                        .font(.system(size: 180, weight: .thin))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 10)
                    
                    Text("Options")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
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
                                .font(.system(size: 55, weight: .thin))
                                .frame(width: 55, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Referral")
                                .font(.system(size: 16, weight: .bold))
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
                                .font(.system(size: 55, weight: .thin))
                                .frame(width: 55, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Support")
                                .font(.system(size: 16, weight: .bold))
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
                                    .font(.system(size: 55, weight: .thin))
                                    .frame(width: 55, height: 35)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Report sent successfully")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Image("bug")
                                    .font(.system(size: 55, weight: .thin))
                                    .frame(width: 55, height: 35)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Report a problem")
                                    .font(.system(size: 16, weight: .bold))
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
                    
                    Button (action:  {
                        showConfirmLogout = true
                    }) {
                        HStack(spacing: 20){
                            Image("logout")
                                .font(.system(size: 55, weight: .thin))
                                .frame(width: 55, height: 35)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Logout")
                                .font(.system(size: 16, weight: .bold))
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(40)
            .padding(.bottom, 10)
        }
    }
}
