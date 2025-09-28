//
//  TokenResult.swift
//  Outline
//
//  Created by Diesperov Konstantin on 25.09.2025.
//

import Foundation

struct TokenResult: Codable{
    let access: String?
    let refresh: String?
    let accessExpired: Date?
}
