//
//  UserApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 17.08.2025.
//

import SwiftUI
import Foundation

class UserApi {
    let baseUrl: String
    
    private let LOG_TAG = "UserApi"
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
        self.baseUrl = Bundle.main.baseUrl + "/User"
    }
    
    public func getSsKey(completion: @escaping (Result<String, Error>) -> Void){
        logger.i("getSsKey started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/GetSSKey") else {
            logger.e("Invalid URL in getSsKey", tag: LOG_TAG)
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
            logger.i("Token attached for getSsKey", tag: LOG_TAG)
        } else {
            logger.w("No token available for getSsKey", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        let started = Date()
        session.dataTask(with: request){ data, response, error in
            let elapsed = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("getSsKey error in \(elapsed)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("getSsKey: No HTTP response in \(elapsed)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            let bytes = data?.count ?? 0
            self.logger.i("← getSsKey HTTP \(http.statusCode), \(bytes) bytes, \(elapsed)ms", tag: self.LOG_TAG)
            
            if http.statusCode == 200 {
                completion(.success(bodyString.unquoted))
                return
            } else {
                let message = bodyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "No authorized"
                : bodyString
                
                self.logger.w("getSsKey failed [code=\(http.statusCode)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func getTariff(completion: @escaping (Result<CurrentTariffModel, Error>) -> Void){
        logger.i("getTariff started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/GetTariff") else {
            logger.e("Invalid URL in getTariff", tag: LOG_TAG)
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
            logger.i("Token attached for getTariff", tag: LOG_TAG)
        } else {
            logger.w("No token available for getTariff", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        let started = Date()
        session.dataTask(with: request){ data, response, error in
            let elapsed = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("getTariff error in \(elapsed)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("getTariff: No HTTP response in \(elapsed)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            let bytes = data?.count ?? 0
            self.logger.i("← getTariff HTTP \(http.statusCode), \(bytes) bytes, \(elapsed)ms", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 {
                if let data = data {
                    do {
                        let tariff: CurrentTariffModel = try DiDecoder.getJson2TariffDecoder().decode(CurrentTariffModel.self, from: data)
                        self.logger.i("Tariff decoded successfully", tag: self.LOG_TAG)
                        completion(.success(tariff))
                    } catch {
                        self.logger.e("Tariff decode failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                        completion(.failure(error))
                    }
                }
                return
            } else {
                let message = bodyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Error getting tariff"
                : bodyString
                
                self.logger.w("getTariff failed [code=\(http.statusCode)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
}
