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
    
    @State private var verticalPaddingBtn: CGFloat = 10
    @State private var user: User?
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                    
                    HStack(spacing: 15){
                        Image("VerticalDivider")
                            .resizable()
                            .frame(width: 6, height: 70)
                            .foregroundColor(Color("TextSecondary"))
                            
                        VStack{
                            Text(user?.email ?? "user")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.body).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            
                            Text(ssManager.serverLocation ?? "• • • • • •")
                                .font(.largeTitle).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .shimmer(ssManager.serverLocation == nil, color: Color("TextSecondary"))
                        }
                        .padding(.vertical, 5)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
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
                            Image("Friends")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Referral")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, verticalPaddingBtn)
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
                            Image("Promo")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Promocode")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, verticalPaddingBtn)
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
                    
                    Button (action:  {
                        showSupportView = true
                    }) {
                        HStack(spacing: 20){
                            Image("SupportBold")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Support")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, verticalPaddingBtn)
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
                                Image("Check")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(Color("Active"))
                                Text("Report sent successfully")
                                    .font(.body).bold()
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Image("Bug")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Report a problem")
                                    .font(.body).bold()
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, verticalPaddingBtn)
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
                                Image("Swap")
                                    .resizable()
                                    .frame(width: 45, height: 45)
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
                        .padding(.vertical, verticalPaddingBtn)
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
                            Image("Logout")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color("TextPrimary"))
                            Text("Logout")
                                .font(.body).bold()
                                .foregroundColor(Color("TextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, verticalPaddingBtn)
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
            .onAppear {
                user = DiStorage.loadUser()
                haptic.prepare()
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
        }
    }
}
