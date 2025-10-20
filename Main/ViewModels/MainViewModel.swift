//
//  MainViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 07.08.2025.
//
import SwiftUI

class MainViewModel: ObservableObject {
    
    private let LOG_TAG: String = "MainViewModel"
    private let logger = DiLogger.shared
    
    func checkUpdate(completion: @escaping (Bool) -> Void){
        logger.i("checkUpdate called", tag: LOG_TAG)
        let appApi = AppApi()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let version = version.replacingOccurrences(of: "-debug", with: "")
            logger.i("App version fetched", tag: LOG_TAG)
            appApi.getLastSupportVersion() { result in
                switch result {
                case .success(let body):
                    self.logger.i("Last support version - \(body.version)", tag: self.LOG_TAG)
                    self.logger.i("Current version - \(version)", tag: self.LOG_TAG)
                    let isActual = self.checkVersion(version, body.version)
                    completion(isActual)
                    return
                case .failure(let error):
                    self.logger.e("checkUpdate error: \(error.localizedDescription)", tag: self.LOG_TAG)
                    completion(true)
                    return
                }
            }
        } else {
            logger.w("checkUpdate: CFBundleShortVersionString not found", tag: LOG_TAG)
        }
    }
    
    private func checkVersion(_ current: String, _ lastSupport: String) -> Bool{
        let currentParts = current.split(separator: ".").map { Int($0) ?? 0 }
        let supportParts = lastSupport.split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(currentParts.count, supportParts.count)
        for i in 0..<maxCount {
            let currentPart = i < currentParts.count ? currentParts[i] : 0
            let supportPart = i < supportParts.count ? supportParts[i] : 0
            if currentPart != supportPart {
                return currentPart < supportPart ? false : true
            }
        }
        return true
    }
    
    func checkVerification(completion: @escaping (Bool) -> Void){
        logger.i("checkVerification called", tag: LOG_TAG)
        do{
            let tokenModel = try DiStorage.loadToken()
            
            if (tokenModel?.access != nil) {
                let authApi = AuthApi()
                authApi.checkAuth(){ result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let body):
                            if body{
                                self.logger.i("checkVerification: authorized", tag: self.LOG_TAG)
                                self.logDevice()
                            } else{
                                self.logger.w("checkVerification: not authorized", tag: self.LOG_TAG)
                                DiStorage.clearToken()
                                DiStorage.clearServer()
                            }
                            completion(body)
                            return
                        case .failure(let error):
                            self.logger.w("checkVerification failed: (\(error.localizedDescription))", tag: self.LOG_TAG)
                            completion(true)
                            return
                        }
                    }
                }
            } else {
                logger.w("checkVerification: no token in storage", tag: LOG_TAG)
                completion(false)
            }
        } catch {
            logger.e("Failed to load token: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func logDevice(){
        logger.i("logDevice called", tag: LOG_TAG)
        
        let deviceApi = DeviceApi()
        deviceApi.loginDevice(){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.logger.i("logDevice success", tag: self.LOG_TAG)
                    break
                case .failure(let error):
                    self.logger.w("logDevice failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    break
                }
            }
        }
    }
}
