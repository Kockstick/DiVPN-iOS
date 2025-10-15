//
//  DiTokenProvider.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.09.2025.
//

import Foundation

struct DiTokenProvider {
    static var shared = DiTokenProvider()
    private static var isRefreshing: Bool = false
    
    private let logger = DiLogger.shared
    private let LOG_TAG = "DiTokenProvider"
    
    mutating func GetAccessToken() async throws -> String? {
        if Self.isRefreshing{
            logger.i("Token is refreshing, wait...", tag: LOG_TAG)
            while Self.isRefreshing{
                try await Task.sleep(nanoseconds: 500_000_000)
                await Task.yield()
            }
            logger.i("Token was refreshed, finish wait.", tag: LOG_TAG)
            return try? DiStorage.loadToken()?.access;
        }
        
        Self.isRefreshing = true
        defer { Self.isRefreshing = false }
        
        guard let lastToken = try? DiStorage.loadToken() else {
            return nil
        }
        
        guard let refreshToken = lastToken.refresh else {
            DiStorage.clearAll()
            AuthState.shared.isAuthorized = false
            return nil
        }
        
        if let expired = lastToken.accessExpired {
            if expired > Date() {
                logger.i("Access token is actual.", tag: LOG_TAG)
                return lastToken.access
            } else{
                logger.w("Access token expired.", tag: LOG_TAG)
            }
        } else {
            logger.w("Access token expiration not set", tag: LOG_TAG)
        }
        
        logger.i("Start refresh token", tag: LOG_TAG)
        
        do{
            let authApi = AuthApi()
            let tokenResult = try await authApi.refresh(refreshToken)
            logger.i("Success refresh token", tag: LOG_TAG)
            return tokenResult?.access
        } catch{
            logger.i("Failed refresh token: \(error)", tag: LOG_TAG)
        }
        
        return nil
    }
}
