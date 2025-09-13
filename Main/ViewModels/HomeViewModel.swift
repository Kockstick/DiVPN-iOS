//
//  HomeViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    private let LOG_TAG: String = "HomeViewModel"
    private let logger = DiLogger.shared
    
    func startVPN(){
        logger.i("startVPN called", tag: LOG_TAG)
        
        ShadowsocksManager.shared.getKey(){ result in
            switch result {
            case .success(let key):
                self.logger.i("SS key obtained, starting VPN", tag: self.LOG_TAG)
                DiVpnService.startVpn(ssKey: key) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.logger.i("VPN start success", tag: self.LOG_TAG)
                        } else {
                            self.logger.e("VPN start failed", tag: self.LOG_TAG)
                            DiStatus.shared.isEnabled = false
                        }
                    }
                }
                break
            case .failure(let error):
                DiStatus.shared.isEnabled = false
                self.logger.e("Failed to obtain SS key: \(error.localizedDescription)", tag: self.LOG_TAG)
                break
            }
        }
    }
    
    func stopVPN(){
        logger.i("stopVPN called", tag: LOG_TAG)
        
        DiVpnService.stopVpn(){
            success in
            DispatchQueue.main.async {
                if success {
                    self.logger.i("VPN stop success", tag: self.LOG_TAG)
                } else {
                    self.logger.w("VPN stop failed; keeping toggle enabled", tag: self.LOG_TAG)
                    DiStatus.shared.isEnabled = true
                }
            }
        }
    }
    
    func checkConnection(){
        logger.i("checkConnection called", tag: LOG_TAG)
        
        DiVpnService.checkConnection(){ result in
            DispatchQueue.main.async{
                self.logger.i("checkConnection result: \(result)", tag: self.LOG_TAG)
                DiStatus.shared.isEnabled = result
            }
        }
    }
}
