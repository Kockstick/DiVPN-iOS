//
//  AuthView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 26.08.2025.
//

import SwiftUI

struct AuthView: View{
    @EnvironmentObject var auth: AuthState
    @EnvironmentObject var referralModel: ReferralManager
    @State private var path: [AuthRoute] = [.email]
    
    var body: some View{
        NavigationStack(path: $path) {
            Color.clear
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .email:
                        EmailView {
                            path.append(.code)
                        }
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                        
                    case .code:
                        CodeView {
                            if let user = DiStorage.loadUser() {
                                let now = Date()
                                let oneDayAgo = now.addingTimeInterval(-244 * 60 * 60)
                                
                                if user.dateRegister <= oneDayAgo {
                                    auth.isAuthorized = true
                                    return
                                }
                            }
                            path.append(.referral)
                        }
                        .navigationBarHidden(true)
                        
                    case .referral:
                        ReferralView{
                            auth.isAuthorized = true
                        }
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    }
                }
        }
        .interactiveDismissDisabled(true)
        .sheet(isPresented: $referralModel.showReferralInviteInAuth){
            ReferralInviteView()
        }
    }
}

// 1) Состояние авторизации
final class AuthState: ObservableObject {
    @Published var isAuthorized = true
}

// 2) Маршруты ТОЛЬКО для auth-флоу
enum AuthRoute: Hashable {
    case email
    case code
    case referral
}
