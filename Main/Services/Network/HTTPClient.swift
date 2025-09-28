//
//  HTTPClient.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.09.2025.
//

import Foundation

final class HTTPClient{
    private let baseURL: URL
    private let session: URLSession
    private var tokenProvider: DiTokenProvider?
    
    private let logger = DiLogger.shared
    private let LOG_TAG = "HTTPClient"
    
    init(baseURL: URL, session: URLSession, tokenProvider: DiTokenProvider? = nil) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }
    
    func send<Response: Decodable>(_ path: String, method: HTTPMethod = .GET, query: [String: String?] = [:],
                                   headers: [String: String] = [:], json body: (any Encodable)? = nil, accept: String = "application/json") async throws -> Response {
        let (data, _) = try await raw(path, method: method, query: query, headers: headers, json: body, accept: accept)
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
    
    func sendText(_ path: String, method: HTTPMethod = .GET, headers: [String: String] = [:], json body: (any Encodable)? = nil, accept: String = "text/plain") async throws -> String {
        let (data, _) = try await raw(path, method: method, headers: headers, json: body, accept: accept)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func sendMultipart(_ path: String, method: HTTPMethod = .POST, headers: [String: String] = [:], body: Data, contentType: String)
    async throws -> String {
        var h = headers
        h["Content-Type"] = contentType
        let (data, _) = try await raw(path, method: method, headers: h, body: body, accept: "text/plain,application/json")
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func sendData(
        _ path: String,
        method: HTTPMethod = .GET,
        query: [String: String?] = [:],
        headers: [String: String] = [:],
        json body: (any Encodable)? = nil,
        accept: String = "application/json",
        acceptStatuses: Set<Int> = []
    ) async throws -> (Data, HTTPURLResponse) {
        try await raw(path, method: method, query: query, headers: headers, json: body, accept: accept, acceptStatuses: acceptStatuses)
    }
    
    private func raw(
        _ path: String,
        method: HTTPMethod,
        query: [String: String?] = [:],
        headers: [String: String] = [:],
        json body: (any Encodable)? = nil,
        accept: String = "application/json",
        acceptStatuses: Set<Int> = []
    ) async throws -> (Data, HTTPURLResponse) {
        let bodyData: Data?
        var h = headers
        if let body {
            do {
                bodyData = try JSONEncoder().encode(AnyEncodable(body))
                h["Content-Type"] = "application/json; charset=utf-8"
            } catch { throw APIError.encoding(error) }
        } else { bodyData = nil }
        
        return try await raw(path, method: method, query: query, headers: h, body: bodyData, accept: accept, acceptStatuses: acceptStatuses)
    }
    
    private func raw(
        _ path: String,
        method: HTTPMethod,
        query: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data?,
        accept: String,
        acceptStatuses: Set<Int> = [],
        refreshed: Bool = false
    ) async throws -> (Data, HTTPURLResponse) {
        var url = baseURL
        let clean = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        url.appendPathComponent(clean)
        
        if query.isEmpty == false {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = query.compactMap { k, v in v.map { URLQueryItem(name: k, value: $0) } }
            url = comps.url!
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.timeoutInterval = 20
        req.setValue(accept, forHTTPHeaderField: "Accept")
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let body { req.httpBody = body }
        
        if var token = try? await self.tokenProvider?.GetAccessToken(), !token.isEmpty {
            token = token.unquoted
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.i("Bearer attached \(clean)", tag: LOG_TAG)
        } else {
            logger.w("No token available for \(clean)", tag: LOG_TAG)
        }
        
        logger.i("→ \(method.rawValue) \(path)", tag: LOG_TAG)
        let started = Date()
        do {
            let (data, resp) = try await session.data(for: req)
            let ms = Int(Date().timeIntervalSince(started) * 1000)
            guard let http = resp as? HTTPURLResponse else { throw APIError.noHTTPResponse() }
            logger.i("← \(method.rawValue) \(clean) HTTP \(http.statusCode), \(data.count) bytes, \(ms)ms", tag: LOG_TAG)
            
            if (200..<300).contains(http.statusCode) || acceptStatuses.contains(http.statusCode) {
                return (data, http)
            } else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                let msg = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                throw APIError.http(http.statusCode, message: msg.isEmpty ? nil : msg, body: String(raw.prefix(2_000)))
            }
        } catch {
            throw (error as? APIError) ?? APIError.transport(error)
        }
    }
}

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: any Encodable) { _encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
