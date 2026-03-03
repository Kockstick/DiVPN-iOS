//
//  OutlineServerApi.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import Foundation

struct OutlineServerApi: Identifiable, Codable {
    let id: UUID
    var name: String
    var apiUrl: String
}
