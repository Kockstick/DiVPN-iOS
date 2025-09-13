//
//  DiVpnService.swift
//  Outline
//
//  Created by Diesperov Konstantin on 07.08.2025.
//

import Foundation
import OutlineTunnel
import SwiftUI

public class DiVpnService{
    private static let tunnelId = Bundle.main.tunnelId
    
    private static let LOG_TAG = "DiVpnService"
    private static let logger = DiLogger.shared
    
    public static func startVpn(ssKey: String, completion: @escaping (Bool) -> Void){
        logger.i("startVpn called", tag: LOG_TAG)
        Task{
            do {
                if try await OutlineVpn.shared.isActive(tunnelId) {
                    logger.i("VPN already active", tag: LOG_TAG)
                    completion(true)
                    return
                }
                
                DiStatus.shared.loading = true
                
                OutlineVpn.initialize()
                
                let serverName = "DiVPN Server"
                
                logger.i("Starting VPN with tunnel ID: \(tunnelId)", tag: LOG_TAG)
                
                let ssConfig = "{transport: \"\(ssKey)\"}\n"
                
                try await OutlineVpn.shared.start(tunnelId, named: serverName, withTransport: ssConfig)
                logger.i("VPN Started", tag: LOG_TAG)
                await UINotificationFeedbackGenerator().notificationOccurred(.success)
                DiStatus.shared.setConnected(value: true)
                DiNotification.shared.hideRow(NSLocalizedString("check_internet", comment: ""))
                completion(true)
            } catch {
                checkNetwork()
                logger.e("VPN start failed: \(error.localizedDescription)", tag: LOG_TAG)
                await UINotificationFeedbackGenerator().notificationOccurred(.error)
                DiStatus.shared.setConnected(value: false)
                completion(false)
            }
        }
    }
    
    public static func stopVpn(completion: @escaping (Bool) -> Void){
        logger.i("stopVpn called", tag: LOG_TAG)
        Task{
            do {
                DiStatus.shared.loading = true
                try await OutlineVpn.shared.stop(tunnelId)
                logger.i("VPN Stopped", tag: LOG_TAG)
                
                if(!DiStatus.shared.connected){
                    checkNetwork()
                }
                DiStatus.shared.setConnected(value: false)
                
                completion(true)
            } catch {
                logger.e("VPN stop failed: \(error.localizedDescription)", tag: LOG_TAG)
                DiStatus.shared.setConnected(value: true)
                completion(false)
            }
        }
    }
    
    static func startVpnAwaitable(ssKey: String) async throws {
        logger.i("startVpnAwaitable called", tag: LOG_TAG)
        do {
            if try await OutlineVpn.shared.isActive(tunnelId) {
                logger.i("VPN already active", tag: LOG_TAG)
                return
            }

            await MainActor.run {
                DiStatus.shared.loading = true
            }

            OutlineVpn.initialize()

            let serverName = Bundle.main.serverName
            logger.i("Starting VPN with tunnel ID: \(tunnelId)", tag: LOG_TAG)

            let ssConfig = "{transport: \"\(ssKey)\"}\n"

            try await OutlineVpn.shared.start(tunnelId, named: serverName, withTransport: ssConfig)
            await UINotificationFeedbackGenerator().notificationOccurred(.success)

            await MainActor.run {
                logger.i("VPN Started", tag: LOG_TAG)
                DiStatus.shared.setConnected(value: true)
                DiNotification.shared.hideRow(NSLocalizedString("check_internet", comment: ""))
            }
        } catch {
           await  UINotificationFeedbackGenerator().notificationOccurred(.error)
            await MainActor.run {
                checkNetwork()
                logger.e("VPN start failed: \(error.localizedDescription)", tag: LOG_TAG)
                DiStatus.shared.setConnected(value: false)
            }
            throw error
        }
    }
    
    static func restartVpnAwaitable(ssKey: String) async throws {
        logger.i("restartVpnAwaitable called", tag: LOG_TAG)
        do {
            if try await OutlineVpn.shared.isActive(tunnelId) {
                logger.i("Stopping existing VPN with tunnel ID: \(tunnelId)", tag: LOG_TAG)
                try await OutlineVpn.shared.stop(tunnelId)
                await MainActor.run {
                    DiStatus.shared.setConnected(value: false)
                }
                logger.i("VPN Stopped", tag: LOG_TAG)
            }
            
            try await startVpnAwaitable(ssKey: ssKey)
            logger.i("VPN Restarted", tag: LOG_TAG)
        } catch {
            await MainActor.run {
                checkNetwork()
                logger.e("VPN restart failed: \(error.localizedDescription)", tag: LOG_TAG)
                DiStatus.shared.setConnected(value: false)
            }
            throw error
        }
    }
    
    public static func checkConnection(completion: @escaping (Bool) -> Void){
        logger.i("checkConnection called", tag: LOG_TAG)
        Task {
            do {
                let isConnected = try await OutlineVpn.shared.isActive(tunnelId)
                logger.i("checkConnection result: \(isConnected)", tag: LOG_TAG)
                DiStatus.shared.setConnected(value: isConnected)
                completion(isConnected)
            } catch {
                logger.e("checkConnection failed: \(error.localizedDescription)", tag: LOG_TAG)
                completion(false)
            }
        }
    }
    
    private static func checkNetwork(){
        logger.i("checkNetwork triggered", tag: LOG_TAG)
        NetworkMonitor.shared.checkInternetAccess() {hasInternet in
            if hasInternet {
                logger.i("Internet is available", tag: LOG_TAG)
                DiNotification.shared.hideRow(NSLocalizedString("check_internet", comment: ""))
            } else{
                logger.w("No internet access", tag: LOG_TAG)
                DiNotification.shared.showRow(NSLocalizedString("check_internet", comment: ""), type: .error)
            }
        }
    }
}
