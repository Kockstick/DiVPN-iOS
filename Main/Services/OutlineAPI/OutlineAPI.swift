//
//  OutlineAPI.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

import Foundation

class OutlineAPI{
    
    private let baseURL: URL
    private let session: URLSession
    
    init(managementURL: String, allowSelfSigned: Bool = false) {
        self.baseURL = URL(string: managementURL)!
        
        if allowSelfSigned {
            let config = URLSessionConfiguration.default
            self.session = URLSession(
                configuration: config,
                delegate: SelfSignedDelegate(),
                delegateQueue: nil
            )
        } else {
            self.session = .shared
        }
    }
    
    func request<T: Decodable>(
        _ path: String,
        method: String,
        body: Any? = nil
    ) async throws -> T {
        
        var request = URLRequest(
            url: baseURL.appendingPathComponent(path)
        )
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        if data.isEmpty {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func requestVoid(
        _ path: String,
        method: String,
        body: Any? = nil
    ) async throws {
        let _: EmptyResponse = try await request(path, method: method, body: body)
    }
    
    struct EmptyResponse: Decodable {}
    
    func getServerInfo() async throws -> OutlineServer {
        try await request("server", method: "GET")
    }
    
    func renameServer(_ name: String) async throws {
        try await requestVoid(
            "name",
            method: "PUT",
            body: ["name": name]
        )
    }
    
    func getKeys() async throws -> [OutlineKey] {
        struct Response: Codable {
            let accessKeys: [OutlineKey]
        }
        
        let response: Response = try await request("access-keys", method: "GET")
        return response.accessKeys
    }
    
    func createKey() async throws -> OutlineKey {
        try await request("access-keys", method: "POST")
    }
    
    func deleteKey(id: String) async throws {
        try await requestVoid("access-keys/\(id)", method: "DELETE")
    }
    
    func renameKey(id: String, name: String) async throws {
        try await requestVoid(
            "access-keys/\(id)/name",
            method: "PUT",
            body: ["name": name]
        )
    }
    
    func addDataLimit(id: Int, bytes: Int64) async throws {
        try await requestVoid(
            "access-keys/\(id)/data-limit",
            method: "PUT",
            body: ["limit": ["bytes": bytes]]
        )
    }
    
    func removeDataLimit(id: Int) async throws {
        try await requestVoid(
            "access-keys/\(id)/data-limit",
            method: "DELETE"
        )
    }
    
    func getTransferredData() async throws -> [TransferredData] {
        let raw: [String: [String: Int64]] =
            try await request("metrics/transfer", method: "GET")
        
        let dict = raw["bytesTransferredByUserId"] ?? [:]
        
        return dict.compactMap { key, value in
            guard let id = Int(key) else { return nil }
            return TransferredData(keyId: id, usedBytes: value)
        }
    }
}
