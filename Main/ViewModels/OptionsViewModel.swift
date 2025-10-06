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
        
        DiStorage.clearAll()
        logger.i("All is cleared", tag: LOG_TAG)

        completion(true)
        logger.i("logout completed", tag: LOG_TAG)
    }
    
    func logoutDevice(){
        logger.i("logoutDevice called", tag: LOG_TAG)
        
        let deviceApi = DeviceApi()
        deviceApi.logoutDevice(){ result in
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
