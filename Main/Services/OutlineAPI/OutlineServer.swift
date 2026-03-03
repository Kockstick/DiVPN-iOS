//
//  OutlineServer.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

struct OutlineServer: Codable {
    let name: String
    let serverId: String
    let metricsEnabled: Bool
    let version: String
    let portForNewAccessKeys: Int
    let hostnameForAccessKeys: String
}
