//
//  ServerApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.09.2025.
//

import SwiftUI
import Foundation

class ServerApi {
    let baseUrl: String
    
    private let LOG_TAG = "ServerApi"
    private let logger = DiLogger.shared
    
    private let session: URLSession = {
#if DEBUG
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        return URLSession(configuration: cfg,
                          delegate: InsecureSessionDelegate(),
                          delegateQueue: nil)
#else
        return URLSession.shared
#endif
    }()
    
    init() {
        self.baseUrl = Bundle.main.baseUrl + "/Server"
    }
    
    public func getServer(completion: @escaping (Result<ServerModel, Error>) -> Void){
        logger.i("GetServer started", tag: LOG_TAG)
        
        let serverId = DiStorage.loadServer()?.id ?? -1
        
        guard let url = URL(string: "\(baseUrl)/GetServer") else {
            logger.e("Invalid URL in GetServer", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1)));
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if var token = DiStorage.loadToken(), !token.isEmpty {
            token = token.unquoted
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.i("Token attached for GetServer", tag: LOG_TAG)
        } else {
            logger.w("No token available for GetServer", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        let started = Date()
        session.dataTask(with: request){ data, response, error in
            let elapsed = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("GetServer error in \(elapsed)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("GetServer: No HTTP response in \(elapsed)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            let bytes = data?.count ?? 0
            self.logger.i("← GetServer HTTP \(http.statusCode), \(bytes) bytes, \(elapsed)ms", tag: self.LOG_TAG)
            
            if http.statusCode == 200 {
                if let data = data {
                    do {
                        let server = try JSONDecoder().decode(ServerModel.self, from: data)
                        self.logger.i("ServerModel decoded successfully", tag: self.LOG_TAG)
                        completion(.success(server))
                    } catch {
                        self.logger.e("ServerModel decode failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                        completion(.failure(error))
                    }
                }
                return
            } else {
                let message = bodyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "No authorized"
                : bodyString
                
                self.logger.w("GetServer failed [code=\(http.statusCode)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func logConnection(_ logConnectionModel: LogConnectionModel, completion: @escaping (Result<Bool, Error>) -> Void){
        logger.i("logConnection started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/LogConnection") else {
            logger.e("Invalid URL in logConnection", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1)));
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if var token = DiStorage.loadToken(), !token.isEmpty {
            token = token.unquoted
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.i("Token attached for logConnection", tag: LOG_TAG)
        } else {
            logger.w("No token available for logConnection", tag: LOG_TAG)
        }
        
        do {
            let payload = logConnectionModel
            request.httpBody = try JSONEncoder().encode(payload)
            logger.i("logConnection payload encoded", tag: LOG_TAG)
        } catch {
            logger.e("Encoding payload failed in logConnection: \(error.localizedDescription)", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        request.timeoutInterval = 20
        
        let started = Date()
        session.dataTask(with: request){ data, response, error in
            let elapsed = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("logConnection error in \(elapsed)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("logConnection: No HTTP response in \(elapsed)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            let bytes = data?.count ?? 0
            self.logger.i("← logConnection HTTP \(http.statusCode), \(bytes) bytes, \(elapsed)ms", tag: self.LOG_TAG)
            
            if http.statusCode == 200 {
                completion(.success(true))
                return
            } else {
                let message = bodyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "No authorized"
                : bodyString
                
                self.logger.w("logConnection failed [code=\(http.statusCode)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
}
