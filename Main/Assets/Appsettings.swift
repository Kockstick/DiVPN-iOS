//
//  Appsettings.swift
//  Outline
//
//  Created by Diesperov Konstantin on 02.09.2025.
//

import Foundation

enum PlistKey {
    static let tunnelId = "TunnelId"
    static let serverName = "ServerName"
    static let baseUrl = "BaseUrl"
    static let privacyPolicyUrl = "PrivacyPolicyUrl"
}

extension Bundle {
    var tunnelId: String {
        return object(forInfoDictionaryKey: PlistKey.tunnelId) as? String ?? "di_vpn_tunnel"
    }
    var serverName: String {
        return object(forInfoDictionaryKey: PlistKey.serverName) as? String ?? "divpn server"
    }
    var baseUrl: String {
        return object(forInfoDictionaryKey: PlistKey.baseUrl) as? String ?? ""
    }
    var privacyPolicyUrl: String{
        return object(forInfoDictionaryKey: PlistKey.privacyPolicyUrl) as? String ?? "divpn.ru"
    }
}
