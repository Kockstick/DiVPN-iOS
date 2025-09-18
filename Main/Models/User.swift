//
//  User.swift
//  Outline
//
//  Created by Diesperov Konstantin on 07.08.2025.
//
import Foundation

struct User: Codable {
    let email: String
    let salt: String
    let dateRegister: Date
    let referralCode: String
    var isUsedReferral: Bool
}
