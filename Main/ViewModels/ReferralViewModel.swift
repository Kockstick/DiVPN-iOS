//
//  ReferralViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

class ReferralViewModel: ObservableObject{
    @Published var loading: Bool = false
    
    private let LOG_TAG: String = "ReferralViewModel"
    private let logger = DiLogger.shared
    
    func useReferral(code: String, completion: @escaping (Bool) -> Void){
        logger.i("Use referral colled", tag: LOG_TAG)
        loading = true
        
        guard let user = DiStorage.loadUser() else{
            logger.e("User not found in storage", tag: LOG_TAG)
            return
        }
    }
}
