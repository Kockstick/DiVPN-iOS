//
//  OutlineServersManager.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import Foundation

class OutlineServersManager: ObservableObject {
    static var shared = OutlineServersManager()
    private var outlineApi: OutlineAPI? = nil
    
    private let idsKey = "outline-server-ids"
    private let serverKeyPrefix = "server-api-"
    private let selectedIdKey = "outline-selected-server-id"
    
    @Published var servers: [OutlineServerApi] = []
    @Published var keys: [OutlineKey] = []
    @Published var isLoadingKeys: Bool = false
    @Published var selected: OutlineServerApi? {
        didSet {
            if let s = selected, let api = selected?.apiUrl {
                UserDefaults.standard.set(s.id.uuidString, forKey: selectedIdKey)
                
                    outlineApi = OutlineAPI(managementURL: api, allowSelfSigned: true)
                    loadKeys()
            } else {
                UserDefaults.standard.removeObject(forKey: selectedIdKey)
                outlineApi = nil
                keys = []
            }
        }
    }
    
    private let LOG_TAG: String = "OutlineServersManager"
    private let logger = DiLogger.shared
    
    func add(_ server: OutlineServerApi) {
        save(server)
        servers.append(server)
    }
    
    func remove(_ server: OutlineServerApi){
        delete(server)
        servers.removeAll { $0.id == server.id }
    }
    
    func getAll() -> [OutlineServerApi] {
        if servers.isEmpty {
            servers = load()
        }
        return servers
    }
    
    func refresh(){
        servers = load()
    }
    
    func selectFirstIfExist(){
        selected = servers.first ?? nil;
    }
    
    func loadKeys() {
        Task{
            guard outlineApi != nil else {
                await MainActor.run {
                    keys = []
                }
                logger.log(.error, tag: LOG_TAG, "Load keys failed: outline api is null")
                return
            }
            
            await MainActor.run {
                isLoadingKeys = true
            }
            
            defer {
                Task { @MainActor in
                    isLoadingKeys = false
                }
            }
            
            do {
                let loadedKeys = try await outlineApi!.getKeys()
                let traffic = try await outlineApi!.getTransferredData()
                
                let trafficMap = Dictionary(
                    uniqueKeysWithValues: traffic.map { ($0.keyId, $0.usedBytes) }
                )
                
                let enrichedKeys = loadedKeys.map { key in
                    var copy = key
                    copy.usedBytes = trafficMap[Int(key.id)!] ?? 0
                    return copy
                }
                
                await MainActor.run {
                    keys = enrichedKeys
                }
            } catch {
                await MainActor.run {
                    keys = []
                }
                logger.log(.error, tag: LOG_TAG, "Error loading keys: \(error.localizedDescription)")
            }
        }
    }
    
    func save(_ server: OutlineServerApi) {
        guard let data = try? JSONEncoder().encode(server) else { return }
        
        KeychainService.save(
            key: serverKeyPrefix + server.id.uuidString,
            value: data
        )
        
        var ids = loadIds()
        if !ids.contains(server.id) {
            ids.append(server.id)
            saveIds(ids)
        }
    }
    
    func restoreSelected() {
        if servers.isEmpty {
            servers = load()
        }
        
        if let idString = UserDefaults.standard.string(forKey: selectedIdKey),
           let uuid = UUID(uuidString: idString),
           let saved = servers.first(where: { $0.id == uuid }) {
            
            selected = saved
            return
        }
        
        selected = servers.first
    }
    
    private func load() -> [OutlineServerApi] {
        let ids = loadIds()
        
        return ids.compactMap { id in
            guard let data = KeychainService.loadData(
                key: serverKeyPrefix + id.uuidString
            ) else { return nil }
            
            return try? JSONDecoder().decode(
                OutlineServerApi.self,
                from: data
            )
        }
    }
    
    func delete(_ server: OutlineServerApi) {
        deleteSelectedKeyIfExist()
        KeychainService.delete(
            key: serverKeyPrefix + server.id.uuidString
        )
        
        var ids = loadIds()
        ids.removeAll { $0 == server.id }
        saveIds(ids)
    }
    
    private func deleteSelectedKeyIfExist(){
        let km = SideKeyManager.shared
        if km.selected == nil { return }
        
        for key in keys {
            if km.selected!.password == key.password {
                km.selected = nil
            }
        }
    }
    
    private func loadIds() -> [UUID] {
        guard let data = UserDefaults.standard.data(forKey: idsKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data)
        else { return [] }
        
        return ids
    }
    
    private func saveIds(_ ids: [UUID]) {
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: idsKey)
        }
    }
}
