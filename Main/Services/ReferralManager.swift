//
//  ReferralManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import Foundation
import SwiftUI

class ReferralManager: ObservableObject{
    static var shared = ReferralManager()
    private let key = "isReferralPromoShowed"
    private let IS_USE_KEY = "isReferralPromoShowed"
    
    @Published var showReferralPromo: Bool = false
    @Published var showReferralInviteInAuth: Bool = false
    @Published var showReferralInviteInMain: Bool = false
    
    var isReferralPromoShowed: Bool {
        get {
            UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    var isReferralUsed: Bool {
        get {
            UserDefaults.standard.bool(forKey: IS_USE_KEY)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: IS_USE_KEY)
        }
    }
}
