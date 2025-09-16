//
//  VerificationResult.swift
//  Outline
//
//  Created by Diesperov Konstantin on 28.08.2025.
//

struct VerificationResult: Codable {
    let token: String?
    let error: VerificationError?
}

enum VerificationError: Int, Codable{
    case IncorrectCode = 0
    case TooManyAttempts = 1
    case CodeExpired = 2
}
