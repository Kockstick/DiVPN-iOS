//
//  OptionsViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 23.08.2025.
//

import SwiftUI

class OptionsViewModel: ObservableObject {
    
    private let LOG_TAG: String = "OptionsViewModel"
    private let logger = DiLogger.shared
    
    func logout(completion: @escaping (Bool) -> Void){
        logger.i("logout called", tag: LOG_TAG)
        
        logoutDevice()
        
        DiVpnService.stopVpn() { result in
            if result {
                self.logger.i("VPN stopped during logout", tag: self.LOG_TAG)
            } else {
                self.logger.w("VPN stop failed during logout", tag: self.LOG_TAG)
            }
        }
        
        DiStorage.clearSsKey()
        logger.i("SS key cleared", tag: LOG_TAG)

        DiStorage.clearToken()
        logger.i("Token cleared", tag: LOG_TAG)

        DiStorage.clearTariff()
        logger.i("Tariff cleared", tag: LOG_TAG)
        
        DiStorage.clearRefCode()
        logger.i("Referral code cleared", tag: LOG_TAG)

        completion(true)
        logger.i("logout completed", tag: LOG_TAG)
    }
    
    func logoutDevice(){
        logger.i("logoutDevice called", tag: LOG_TAG)
        
        guard var user = DiStorage.loadUser() else {
            logger.w("logoutDevice: user not found in storage", tag: LOG_TAG)
            return
        }
        
        let deviceApi = DeviceApi()
        deviceApi.logoutDevice(user){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.logger.i("Device logout success", tag: self.LOG_TAG)
                    break
                case .failure(let error):
                    self.logger.w("Device logout error: \(error.localizedDescription)", tag: self.LOG_TAG)
                    break
                }
            }
        }
    }
}
