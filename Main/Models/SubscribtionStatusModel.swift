//
//  AgreementStatusModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 28.09.2025.
//

public struct SubscribtionStatusModel: Codable {
    let status: StatusSubscribtion
}

public enum StatusSubscribtion: Int, Codable {
    case trial = 0
    case active = 1
    case pastDue = 2
    case cancelled = 3
    case expired = 4
    case trialExpired = 5
    case trialActive = 6
}
