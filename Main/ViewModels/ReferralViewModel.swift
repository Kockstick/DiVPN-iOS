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
        
        var userApi = UserApi()
        userApi.useReferral(code: code) { result in
            switch result{
            case .success(let response):
                if response{
                    self.logger.i("useReferral success, updating user", tag: self.LOG_TAG)
                    if var user = DiStorage.loadUser(){
                        user.isUsedReferral = true
                        DiStorage.saveUser(user: user)
                    } else {
                        self.logger.w("User not found in storage when trying to mark referral", tag: self.LOG_TAG)
                    }
                    completion(true)
                } else{
                    self.logger.w("useReferral returned false response", tag: self.LOG_TAG)
                    completion(false)
                }
                break
            case .failure(let error):
                self.logger.e("useReferral failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(false)
                break
            }
        }
    }
}
