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
    
    @State private var showConfirmLogout = false
    @State private var showBugReport = false
    @State private var showRateView = false
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
                        .frame(height: 2)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    HStack{
                        Button (action: {
                            showRateView = true
                        }) {
                            VStack{
                                Image("star_rate")
                                    .font(.system(size: 100, weight: .thin))
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Rate")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 10).fill(Color("Surface"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(Color("Border"), lineWidth: 2)
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showRateView) {
                            RateView()
                        }
                        
                        Button (action:  {
                            showSupportView = true
                        }) {
                            VStack{
                                Image("support")
                                    .font(.system(size: 80, weight: .thin))
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Support")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 10).fill(Color("Surface"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(Color("Border"), lineWidth: 2)
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showSupportView) {
                            SupportView()
                        }
                    }
                    
                    Button(action: {
                        showBugReport = true
                    }) {
                        HStack(spacing: 2){
                            if bugReportSent{
                                Image("check")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("Active"))
                                Text("Report sent successfully")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxHeight: 55)
                            } else {
                                Text("Report a problem")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxHeight: 55)
                                Image("bug")
                                    .font(.system(size: 35, weight: .light))
                                    .foregroundColor(Color("TextPrimary"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(Color("Surface"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Color("Border"), lineWidth: 2)
                    )
                    .sheet(isPresented: $showBugReport) {
                        ReportView(bugReportSent: $bugReportSent)
                    }
                    .disabled(bugReportSent)
                    .compositingGroup()
                    
                    Spacer()
                    
                    Button(action: {
                        showConfirmLogout = true
                    }) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("TextPrimaryFixed"))
                            .frame(maxWidth: .infinity, maxHeight: 55)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Error"))
                            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Border"), lineWidth: 2)
                    )
                    .confirmationDialog("Are you shure?", isPresented: $showConfirmLogout) {
                        Button("Logout", role: .destructive) {
                            vm.logout() { result in
                                auth.isAuthorized = false
                            }
                        }
                        Button("Cansel", role: .cancel) {}
                    }
                    .compositingGroup()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(40)
            .padding(.bottom, 10)
            .background(
                GeometryReader { proxy in
                    Image("settings")
                        .font(.system(size: 500, weight: .medium))
                        .frame(alignment: .bottomLeading)
                        .foregroundColor(Color("TextSecondary"))
                        .opacity(colorScheme == .dark ? 0.03 : 0.06)
                        .offset(x: -280, y: 150)
                })
        }
    }
}
