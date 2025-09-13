//
//  DiDecoder.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.08.2025.
//

import Foundation

internal class DiDecoder{
    private static let LOG_TAG: String = "DiDecoder"
    
    internal static func getJson2UserDecoder() -> JSONDecoder {
        let dec = JSONDecoder()
        
        dec.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            if let n = try? c.decode(Double.self) {
                return n > 10_000_000_000 ? Date(timeIntervalSince1970: n/1000) : Date(timeIntervalSince1970: n)
            }
            let s = try c.decode(String.self)
            let isoFS = ISO8601DateFormatter()
            isoFS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = isoFS.date(from: s) { return d }
            let iso = ISO8601DateFormatter()
            if let d = iso.date(from: s) { return d }
            let f = DateFormatter()
            f.locale = .init(identifier: "en_US_POSIX")
            f.timeZone = .init(secondsFromGMT: 0)
            for fmt in ["yyyy-MM-dd'T'HH:mm:ssXXXXX",
                        "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                        "yyyy-MM-dd HH:mm:ss",
                        "yyyy-MM-dd"] {
                f.dateFormat = fmt
                if let d = f.date(from: s) { return d }
            }
            DiLogger.shared.e("Unsupported date format in UserDecoder: \(s)", tag: LOG_TAG)
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported date: \(s)")
        }
        return dec
    }
    
    internal static func getJson2TariffDecoder() -> JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            if let n = try? c.decode(Double.self) {
                return n > 10_000_000_000
                ? Date(timeIntervalSince1970: n / 1000)
                : Date(timeIntervalSince1970: n)
            }
            let s = try c.decode(String.self)
            let isoFS = ISO8601DateFormatter()
            isoFS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = isoFS.date(from: s) { return d }
            let iso = ISO8601DateFormatter()
            if let d = iso.date(from: s) { return d }
            let f = DateFormatter()
            f.locale = .init(identifier: "en_US_POSIX")
            f.timeZone = .init(secondsFromGMT: 0)
            for fmt in [
                "yyyy-MM-dd'T'HH:mm:ssXXXXX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd"
            ] {
                f.dateFormat = fmt
                if let d = f.date(from: s) { return d }
            }
            DiLogger.shared.e("Unsupported date format in TariffDecoder: \(s)", tag: LOG_TAG)
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported date: \(s)")
        }
        return dec
    }
    
    internal static func getJson2VerificationResultDecoder() -> JSONDecoder {
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        return dec
    }
}
