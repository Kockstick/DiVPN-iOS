//
//  SideKeyManager.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 01.03.2026.
//

import SwiftUI

class SideKeyManager: ObservableObject {
    static var shared = SideKeyManager()
    
    private let selectedKeyStorageKey = "outline-selected-key"
    private let customKeyStorageKey = "custom-outline-key"
    
    private let LOG_TAG: String = "SideKeyManager"
    private let logger = DiLogger.shared
    
    @Published var selected: OutlineKey? {
        didSet {
            guard let selected else {
                KeychainService.delete(key: selectedKeyStorageKey)
                return
            }
            
            guard let data = try? JSONEncoder().encode(selected) else { return }
            
            KeychainService.save(
                key: selectedKeyStorageKey,
                value: data
            )
        }
    }
    
    @Published var customKey: OutlineKey? {
        didSet {
            guard let customKey else {
                deleteCustomKey()
                return
            }
            saveCustomKey(customKey)
        }
    }
    
    init() {
        restoreSelectedKey()
        if let key = loadCustomKey(){
            self.customKey = key
        }
    }
    
    func restoreSelectedKey() {
        guard
            let data = KeychainService.loadData(key: selectedKeyStorageKey),
            let savedKey = try? JSONDecoder().decode(OutlineKey.self, from: data)
        else {
            selected = nil
            logger.log(.info, "Side key not selected")
            return
        }
        
        selected = savedKey
    }
    
    func rename(_ key: OutlineKey, _ name: String, _ server: OutlineServerApi, completion: @escaping () -> Void) {
        Task{
            do{
                let outline = OutlineAPI(managementURL: server.apiUrl, allowSelfSigned: true)
                try await outline.renameKey(id: key.id, name: name)
                completion()
                OutlineServersManager.shared.loadKeys()
            } catch {
                logger.log(.error, tag: LOG_TAG, "Error rename outline key \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    func delete(_ key: OutlineKey, _ server: OutlineServerApi, completion: @escaping () -> Void){
        Task{
            do{
                let outline = OutlineAPI(managementURL: server.apiUrl, allowSelfSigned: true)
                try await outline.deleteKey(id: key.id)
                completion()
                OutlineServersManager.shared.loadKeys()
            } catch {
                logger.log(.error, tag: LOG_TAG, "Error delete outline key \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    func create(_ server: OutlineServerApi, completion: @escaping (_ key: OutlineKey?) -> Void){
        Task{
            do{
                let outline = OutlineAPI(managementURL: server.apiUrl, allowSelfSigned: true)
                let key = try await outline.createKey()
                completion(key)
                OutlineServersManager.shared.loadKeys()
            } catch {
                logger.log(.error, tag: LOG_TAG, "Error create outline key \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func saveCustomKey(_ key: OutlineKey) {
        guard let data = try? JSONEncoder().encode(key) else {
            logger.log(.error, tag: LOG_TAG, "Failed to encode OutlineKey")
            return
        }
        
        KeychainService.save(
            key: customKeyStorageKey,
            value: data
        )
        
        logger.log(.info, tag: LOG_TAG, "Custom OutlineKey saved")
    }
    
    func loadCustomKey() -> OutlineKey? {
        guard
            let data = KeychainService.loadData(key: customKeyStorageKey),
            let key = try? JSONDecoder().decode(OutlineKey.self, from: data)
        else {
            logger.log(.info, tag: LOG_TAG, "Custom OutlineKey not found")
            return nil
        }
        
        return key
    }
    
    func deleteCustomKey() {
        KeychainService.delete(key: customKeyStorageKey)
        logger.log(.info, tag: LOG_TAG, "Custom OutlineKey deleted")
    }
}
