//
//  BasedTypes.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.09.2025.
//

import Foundation

enum APIError: Error {
    case invalidURL(_ url: String? = nil)
    case noHTTPResponse(url: String? = nil)
    case http(_ status: Int, message: String?, url: String? = nil, body: String? = nil)
    case encoding(Error)
    case decoding(Error)
    case transport(Error)
}

// MARK: - Human-friendly messages
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let u):
            return "Неверный URL" + (u.flatMap { ": \($0)" } ?? "")
        case .noHTTPResponse(let url):
            return "Нет HTTP-ответа от сервера" + (url.flatMap { " (\($0))" } ?? "")
        case .http(let code, let msg, let url, _):
            var s = "HTTP \(code)"
            if let m = msg, !m.isEmpty { s += ": \(m)" }
            if let u = url { s += " (\(u))" }
            return s
        case .encoding(let e):
            return "Ошибка кодирования запроса: \(e.localizedDescription)"
        case .decoding(let e):
            return "Ошибка разбора ответа: \(e.localizedDescription)"
        case .transport(let e):
            return "Сетевой сбой: \(e.localizedDescription)"
        }
    }
}

// MARK: - NSError bridge (для нормальных domain/code/userInfo)
extension APIError: CustomNSError {
    static var errorDomain: String { "DiVPN.APIError" }

    var errorCode: Int {
        switch self {
        case .invalidURL: return 1
        case .noHTTPResponse: return 2
        case .http(let status, _, _, _): return status
        case .encoding: return 11
        case .decoding: return 12
        case .transport: return 13
        }
    }

    var errorUserInfo: [String : Any] {
        var info: [String: Any] = [NSLocalizedDescriptionKey: errorDescription ?? "Ошибка"]
        switch self {
        case .invalidURL(let url):
            if let url { info["url"] = url }
        case .noHTTPResponse(let url):
            if let url { info["url"] = url }
        case .http(_, _, let url, let body):
            if let url { info["url"] = url }
            if let body, !body.isEmpty { info["response_body"] = body }
        case .transport(let underlying):
            info[NSUnderlyingErrorKey] = underlying
        default:
            break
        }
        return info
    }
}

// MARK: - Удобные аксессоры/помощники
extension APIError {
    var httpStatus: Int? {
        if case .http(let s, _, _, _) = self { return s }
        return nil
    }
    var responseBody: String? {
        if case .http(_, _, _, let b) = self { return b }
        return nil
    }
    static func isUnauthorized(_ error: Error) -> Bool {
        (error as? APIError)?.httpStatus == 401
    }
}


enum HTTPMethod: String { case GET, POST, PUT, PATCH, DELETE }
