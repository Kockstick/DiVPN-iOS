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
            logger.i("App version fetched", tag: LOG_TAG)
            let appVersion = AppVersionModel(version: version)
            appApi.checkUpdate(appVersion) { result in
                switch result {
                case .success(let body):
                    print("Is actual version - \(body)")
                    if let flag = Bool(body) {
                        self.logger.i("checkUpdate success: isActual=\(flag)", tag: self.LOG_TAG)
                        completion(!flag)
                        return
                    }
                    self.logger.w("checkUpdate: unable to parse server body as Bool", tag: self.LOG_TAG)
                    completion(false)
                    return
                case .failure(let error):
                    self.logger.e("checkUpdate error: \(error.localizedDescription)", tag: self.LOG_TAG)
                    print("Error get version app: \(error)")
                    completion(false)
                    return
                }
            }
        } else {
            logger.w("checkUpdate: CFBundleShortVersionString not found", tag: LOG_TAG)
        }
    }
    
    func checkVerification(completion: @escaping (Bool) -> Void){
        logger.i("checkVerification called", tag: LOG_TAG)
        if ((try? DiStorage.loadToken()?.access != nil) != nil) {
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
