//
//  OutlineKey.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

struct OutlineKey: Codable {
    let id: String
    let name: String?
    let password: String
    let port: Int
    let method: String
    let dataLimit: DataLimit?
    let accessUrl: String
    
    var usedBytes: Int64 = 0
    
    enum CodingKeys: String, CodingKey {
        case id, name, password, port, method, dataLimit, accessUrl
    }
}
