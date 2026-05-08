import Foundation
import SwiftUI

public class DiVpnService {
    private static let tunnelId = Bundle.main.tunnelId
    private static let LOG_TAG = "DiVpnService"
    private static let logger = DiLogger.shared
    private static let xray = Xray.shared
    
    // MARK: - Public API (completion-based)
    public static func startVpn(ssKey: String, completion: @escaping (Bool) -> Void) {
        logger.i("startVpn called", tag: LOG_TAG)
        Task {
            do {
                try await performStart(ssKey: ssKey)
                completion(true)
            } catch {
                handleStartError(error)
                completion(false)
            }
        }
    }
    
    public static func stopVpn(completion: @escaping (Bool) -> Void) {
        logger.i("stopVpn called", tag: LOG_TAG)
        Task {
            await setLoading(true)
            xray.stop()
            logger.i("VPN Stopped", tag: LOG_TAG)
            if !DiStatus.shared.connected {
                checkNetwork()
            }
            await setConnected(false)
            completion(true)
        }
    }
    
    // MARK: - Public API (async/await)
    
    static func startVpnAwaitable(ssKey: String) async throws {
        logger.i("startVpnAwaitable called", tag: LOG_TAG)
        do {
            try await performStart(ssKey: ssKey)
        } catch {
            handleStartError(error)
            throw error
        }
    }
    
    static func restartVpnAwaitable(ssKey: String) async throws {
        logger.i("restartVpnAwaitable called", tag: LOG_TAG)
        do {
            if xray.isActive {
                logger.i("Stopping existing VPN with tunnel ID: \(tunnelId)", tag: LOG_TAG)
                xray.stop()
                await setConnected(false)
                logger.i("VPN Stopped", tag: LOG_TAG)
            }
            try await performStart(ssKey: ssKey)
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
    
    public static func checkConnection(completion: @escaping (Bool) -> Void) {
        logger.i("checkConnection called", tag: LOG_TAG)
        Task {
            let isConnected = xray.isActive
            logger.i("checkConnection result: \(isConnected)", tag: LOG_TAG)
            await setConnected(isConnected)
            completion(isConnected)
        }
    }
    
    // MARK: - Core start logic (single source of truth)
    
    private static func performStart(ssKey: String) async throws -> Void {
        if xray.isActive {
            logger.i("VPN already active", tag: LOG_TAG)
            return
        }
        
        await setLoading(true)
        
        logger.i("Starting VPN", tag: LOG_TAG)
        let started = Date()
        do{
            try xray.start(with: ssKey)
            let ms = (Float)(Date().timeIntervalSince(started) * 1000)
            
            logger.i("VPN started in \(ms) ms", tag: LOG_TAG)
            
            await UINotificationFeedbackGenerator().notificationOccurred(.success)
            await handleStartSuccess()
            
            Task{
                let serverApi = ServerApi()
                _ = try? await serverApi.logConnection(ms)
            }
        } catch{
            Task{
                let serverApi = ServerApi()
                _ = try? await serverApi.logConnection(0, message: error.localizedDescription)
            }
            logger.e("VPN not started: \(error.localizedDescription)", tag: LOG_TAG)
        }
    }
    
    // MARK: - Shared handlers
    @MainActor
    private static func handleStartSuccess() {
        logger.i("VPN Started", tag: LOG_TAG)
        DiStatus.shared.setConnected(value: true)
        DiNotification.shared.hideRow(NSLocalizedString("check_internet", comment: ""))
    }
    
    private static func handleStartError(_ error: Error) {
        Task { @MainActor in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            checkNetwork()
            logger.e("VPN start failed: \(error.localizedDescription)", tag: LOG_TAG)
            DiStatus.shared.setConnected(value: false)
        }
    }
    
    // MARK: - UI state helpers
    @MainActor
    private static func setLoading(_ value: Bool) {
        DiStatus.shared.loading = value
    }
    
    @MainActor
    private static func setConnected(_ value: Bool) {
        DiStatus.shared.setConnected(value: value)
    }
    
    // MARK: - Network hint
    private static func checkNetwork() {
        logger.i("checkNetwork triggered", tag: LOG_TAG)
        NetworkMonitor.shared.checkInternetAccess() { hasInternet in
            if hasInternet {
                logger.i("Internet is available", tag: LOG_TAG)
                DiNotification.shared.hideRow(NSLocalizedString("check_internet", comment: ""))
            } else {
                logger.w("No internet access", tag: LOG_TAG)
                DiNotification.shared.showRow(NSLocalizedString("check_internet", comment: ""), type: .error)
            }
        }
    }
}
