//
//  AgeementModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 30.09.2025.
//

struct AgreementModel: Codable{
    let typeDevice: TypeDevice
    let typeAgreement: TypeAgreement
}

enum TypeAgreement: Int, Codable{
    case PublicOffer = 0
    case PrivacyPolicy = 1
}
