//
//  ApiConfig.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

struct ApiConfig: Decodable {
    let apiUrl: String
    let certSha256: String?
}
