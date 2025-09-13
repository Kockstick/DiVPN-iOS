//
//  CurrentTariffModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import Foundation

struct CurrentTariffModel: Codable {
    let name: String
    let description: String
    let days: Int
    let price: Int?
    let discount: Int?
    let dateStart: Date
    let dateEnd: Date
}
