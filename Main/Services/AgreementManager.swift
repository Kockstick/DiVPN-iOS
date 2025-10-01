//
//  AgreementManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 30.09.2025.
//

import SwiftUI

class AgreementManager: ObservableObject{
    static var shared = AgreementManager()
    
    @Published var isPrivacyPolicyAccept = false
    @Published var isPublicOfferAgreed = false
}
