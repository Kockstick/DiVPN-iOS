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
                    if var user = DiStorage.loadUser(){
                        user.isUsedReferral = true
                        DiStorage.saveUser(user: user)
                    }
                    completion(true)
                } else{
                    completion(false)
                }
                break
            case .failure(let error):
                completion(false)
                break
            }
        }
    }
}
