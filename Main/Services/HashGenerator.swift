//
//  HashGenerator.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.08.2025.
//

import Foundation
import CommonCrypto

enum HashError: Error {
    case utf8EncodingFailed
    case derivationFailed(status: CCCryptorStatus)
}

internal struct HashGenerator {
    private static let LOG_TAG = "HashGenerator"
    private static let logger = DiLogger.shared
    
    /// PBKDF2 with HMAC-SHA512, 100_000 iterations, 512-bit key. Base64 output.
    internal static func generateHash(salt: String, input: String) throws -> String {
        logger.i("generateHash called", tag: LOG_TAG)
        
        guard let pwdData = input.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            logger.e("UTF-8 encoding failed", tag: LOG_TAG)
            throw HashError.utf8EncodingFailed
        }

        let keyLen = 64 // 512 bits
        var derivedKey = Data(count: keyLen)

        let status = derivedKey.withUnsafeMutableBytes { dkPtr in
            pwdData.withUnsafeBytes { pwdPtr in
                saltData.withUnsafeBytes { saltPtr in
                    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                         // password
                                         pwdPtr.bindMemory(to: Int8.self).baseAddress!, pwdData.count,
                                         // salt
                                         saltPtr.bindMemory(to: UInt8.self).baseAddress!, saltData.count,
                                         // PRF
                                         CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                                         // iterations
                                         100_000,
                                         // output
                                         dkPtr.bindMemory(to: UInt8.self).baseAddress!, keyLen)
                }
            }
        }

        guard status == kCCSuccess else {
            logger.e("PBKDF2 derivation failed, status=\(status)", tag: LOG_TAG)
            throw HashError.derivationFailed(status: status)
        }

        logger.i("generateHash success", tag: LOG_TAG)
        return derivedKey.base64EncodedString()
    }
}
