//
//  ServerModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.09.2025.
//

import SwiftUI

struct ServerModel: Codable{
    let id: Int
    let name: String
    let location: String
    let dateCreate: String
    let shadowsocksKey: String
}
