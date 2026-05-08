//
//  Xray.swift
//  DiVPN
//
//  Created by admin on 08.05.2026.
//

import NetworkExtension

class Xray {
    static let shared = Xray()
    private var manager: NETunnelProviderManager?
    
    private let logger = DiLogger.shared
    private final let LOG_TAG = "Xray"
    private final let bundleId = "kockstik.ios.client.PacketTunnelProvider"
    
    var isActive: Bool {
        get {
            if (manager != nil) {
                return manager?.connection.status == .connected
            }
            return false
        }
    }
    
    private init(){
        loadManager() { _ in }
    }
    
    func setupManager() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()

        if let existing = managers.first {
            manager = existing
        } else {
            manager = NETunnelProviderManager()
        }

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = bundleId
        proto.serverAddress = Bundle.main.serverName

        manager?.protocolConfiguration = proto
        manager?.localizedDescription = "DiVPN"
        manager?.isEnabled = true

        try await manager?.saveToPreferences()
        try await manager?.loadFromPreferences()
    }
    
    func start(with key: String) throws {
        guard manager != nil else {
            loadManager() { [weak self] error in
                if let error = error {
                    self?.logger.e("Error start xray: \(error)", tag: self?.LOG_TAG ?? "")
                    return
                }
                try? self?.start(with: key)
            }
            return
        }
        
        try manager?.connection.startVPNTunnel(options: ["config": key as NSObject])
    }

    func stop() {
        manager?.connection.stopVPNTunnel()
    }
    
    private func loadManager(_ completion: @escaping (Error?) -> Void) {
        Task {
            do{
                manager = try await getManager()
                if manager == nil {
                    try await setupManager()
                }
                completion(nil)
            } catch {
                logger.e("Failed loading manager: \(error)", tag: LOG_TAG)
                completion(error)
            }
        }
    }
    
    func getManager() async throws -> NETunnelProviderManager? {
        try await NETunnelProviderManager.loadAllFromPreferences().first
    }
}
