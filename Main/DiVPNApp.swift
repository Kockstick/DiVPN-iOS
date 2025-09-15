//
//  DiVPNApp.swift
//  Outline
//
//  Created by Diesperov Konstantin on 08.08.2025.
//

import SwiftUI

@main
struct OutlineApp: App {
    @StateObject private var auth = AuthState()
    @StateObject private var tariffManager = TariffManager.shared
    @StateObject var referralModel = ReferralManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(auth)
                .environmentObject(tariffManager)
                .environmentObject(referralModel)
                .fullScreenCover(isPresented: .constant(!auth.isAuthorized)) {
                    AuthView()
                        .environmentObject(auth)
                        .environmentObject(referralModel)
                }
        }
    }
}
