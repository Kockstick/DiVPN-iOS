//
//  Device.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import Foundation

struct Device: Codable {
    let hashSerialNumber: String
    let typeDevice: TypeDevice
}

enum TypeDevice: Int, Codable{
    case Android = 0
    case AndroidTV = 1
    case iOS = 2
    case MacOS = 3
    case Windows = 4
    case Linux = 5
}
