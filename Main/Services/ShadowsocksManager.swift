//
//  ShadowsocksManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 20.08.2025.
//

import SwiftUI

class ShadowsocksManager: ObservableObject {
    public static let shared = ShadowsocksManager()
    
    @Published var isWaitSsKey: Bool = false
    @Published var serverLocation: String?
    private var ssKey: String = ""
    
    private let LOG_TAG = "ShadowsocksManager"
    private let logger = DiLogger.shared
    
    func preloadKey(){
       getKey(){ result in
            switch result {
            case .success(let key):
                self.ssKey = key
                self.logger.i("Success preload SS key", tag: self.LOG_TAG)
                self.logger.i("Server location - \(self.serverLocation)", tag: self.LOG_TAG)
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.logger.e("Failed to obtain SS key: \(error.localizedDescription)", tag: self.LOG_TAG)
                }
                break
            }
        }
    }
    
    func getKey(completion: @escaping (Result<String, Error>) -> Void){
        logger.i("getKey called", tag: LOG_TAG)
        
        guard let key = DiStorage.loadServer()?.shadowsocksKey else {
            logger.w("No SS key in storage; requesting from server", tag: LOG_TAG)
            isWaitSsKey = true
            
            let serverApi = ServerApi()
            
            serverApi.getServer(){ result in
                switch result {
                case .success(let body):
                    DiStorage.saveServer(body)
                    ShadowsocksManager.shared.serverLocation = body.location
                    self.logger.i("Server received and saved", tag: self.LOG_TAG)
                    self.isWaitSsKey = false
                    completion(.success(body.shadowsocksKey))
                    break
                    
                case .failure(let error):
                    self.logger.e("Failed to get SS key: \(error.localizedDescription)", tag: self.LOG_TAG)
                    completion(.failure(error))
                    break
                }
            }
            return
        }
        logger.i("SS key loaded from storage", tag: LOG_TAG)
        DispatchQueue.main.async {
            ShadowsocksManager.shared.serverLocation = DiStorage.loadServer()?.location
            self.isWaitSsKey = false
        }
        completion(.success(key))
    }
    
    func changeKey(completion: @escaping (Result<Bool, Error>) -> Void){
        logger.i("changeKey called", tag: LOG_TAG)
        
        guard let server = DiStorage.loadServer() else {
            logger.w("No server in storage", tag: LOG_TAG)
            completion(.success(false))
            return
        }
        
        isWaitSsKey = true
        let serverApi = ServerApi()
        serverApi.changeServer(server){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.isWaitSsKey = false
                    
                    if let server = DiStorage.loadServer() {
                        if server.id == body.id{
                            self.logger.i("Server unchanged", tag: self.LOG_TAG)
                            completion(.success(false))
                            return
                        }
                    }
                    
                    ShadowsocksManager.shared.serverLocation = body.location
                    DiStorage.saveServer(body)
                    self.logger.i("Server updated in storage.", tag: self.LOG_TAG)
                    completion(.success(true))
                    
                    if(DiStatus.shared.connected){
                        self.logger.i("VPN connected; restarting with new SS key", tag: self.LOG_TAG)
                        Task{
                            do {
                                try await DiVpnService.restartVpnAwaitable(ssKey: body.shadowsocksKey)
                                self.logger.i("VPN restarted with new SS key", tag: self.LOG_TAG)
                            } catch {
                                DiStatus.shared.isEnabled = false
                                self.logger.e("VPN restart with new SS key failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                                return
                            }
                        }
                    }
                    break
                case .failure(let error):
                    self.logger.w("Failed to refresh SS key: \(error.localizedDescription)", tag: self.LOG_TAG)
                    completion(.failure(error))
                    break
                }
            }
        }
    }
}
