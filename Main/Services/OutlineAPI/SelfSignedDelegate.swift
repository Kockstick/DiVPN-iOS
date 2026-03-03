//
//  SelfSignedDelegate.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

import Foundation

final class SelfSignedDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        guard let trust = challenge.protectionSpace.serverTrust else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        return (.useCredential, URLCredential(trust: trust))
    }
}
