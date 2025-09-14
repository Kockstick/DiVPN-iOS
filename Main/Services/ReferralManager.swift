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
    
    @Published var showReferralPromo: Bool = false
    @Published var showReferralInvite: Bool = false
    
    var isReferralPromoShowed: Bool {
        get {
            UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
}
