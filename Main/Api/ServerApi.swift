//
//  ServerApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.09.2025.
//

import SwiftUI
import Foundation

class ServerApi {
    let client: HTTPClient
    
    private let LOG_TAG = "ServerApi"
    private let logger = DiLogger.shared
    
    init() {
        let baseUrl = URL(string: Bundle.main.baseUrl + "/Server")!
        
#if DEBUG
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        let session = URLSession(configuration: cfg,delegate: InsecureSessionDelegate(),delegateQueue: nil)
#else
        let session = URLSession.shared
#endif
        
        self.client = HTTPClient(baseURL: baseUrl, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func getServer() async throws -> ServerModel {
        return try await client.send(
            "GetServer",
            method: .GET,
            accept: "application/json"
        ) as ServerModel
    }
    
    public func getServer(completion: @escaping (Result<ServerModel, Error>) -> Void) {
        logger.i("getServer called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("getServer success", tag: LOG_TAG)
                completion(.success(try await getServer()))
            }
            catch {
                logger.e("getServer failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func logConnection(_ model: LogConnectionModel) async throws -> Bool {
        let (data, _) = try await client.sendData(
            "LogConnection",
            method: .POST,
            json: model,
            accept: "application/json,text/plain"
        )
        
        if data.isEmpty { return true }
        if let v = try? JSONDecoder().decode(Bool.self, from: data) { return v }
        if let s = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        {
            if s == "true" { return true }
            if s == "false" { return false }
        }
        return true
    }
    
    public func logConnection(_ model: LogConnectionModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        logger.i("logConnection called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("logConnection success", tag: LOG_TAG)
                completion(.success(try await logConnection(model)))
            }
            catch {
                logger.e("logConnection failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
}
