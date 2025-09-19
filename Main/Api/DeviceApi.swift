//
//  DeviceApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import SwiftUI
import Foundation

class DeviceApi{
    let baseUrl: String
    
    private let LOG_TAG: String = "DeviceApi"
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
        self.baseUrl = Bundle.main.baseUrl + "/Device"
    }
    
    public func loginDevice(_ user: User, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("loginDevice started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/LoginDevice") else {
            logger.e("Invalid URL in loginDevice", tag: LOG_TAG)
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
            logger.i("Token attached for loginDevice", tag: LOG_TAG)
        } else {
            logger.w("No token available for loginDevice", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        do {
            let payload = DiStorage.loadDevice()
            request.httpBody = try JSONEncoder().encode(payload)
            logger.i("loginDevice payload encoded", tag: LOG_TAG)
        } catch {
            logger.e("Encoding payload failed in loginDevice: \(error.localizedDescription)", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        let started = Date()
        session.dataTask(with: request) { data, response, error in
            let elapsedMs: Int = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("loginDevice error in \(elapsedMs)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error)); return
            }
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("loginDevice: No HTTP response in \(elapsedMs)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3))); return
            }
            
            let status: Int = http.statusCode
            let bytes: Int = data?.count ?? 0
            self.logger.i("← loginDevice HTTP \(status), \(bytes) bytes, \(elapsedMs)ms", tag: self.LOG_TAG)
            
            let bodyString: String = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 {
                self.logger.i("loginDevice success", tag: self.LOG_TAG)
                completion(.success(bodyString))
            } else {
                struct Problem: Decodable { let title: String?; let errors: [String:[String]]? }
                var message = "HTTP \(status)"
                if let data = data, let p = try? JSONDecoder().decode(Problem.self, from: data) {
                    message = p.errors?.values.first?.first ?? p.title ?? message
                } else if !bodyString.isEmpty {
                    message = bodyString
                }
                self.logger.w("loginDevice failed [code=\(status)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: status,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func logoutDevice(_ user: User, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("logoutDevice started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/LogoutDevice") else {
            logger.e("Invalid URL in logoutDevice", tag: LOG_TAG)
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
            logger.i("Token attached for logoutDevice", tag: LOG_TAG)
        } else {
            logger.w("No token available for logoutDevice", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        guard let id = UIDevice.current.identifierForVendor?.uuidString else {
            logger.e("Failed to get identifierForVendor", tag: LOG_TAG)
            completion(.failure(NSError(domain: "Failed get uuid", code: -1)));
            return
        }
        
        do {
            let payload = Device(hashSerialNumber: try HashGenerator.generateHash(salt: user.salt, input: id),
                                 typeDevice: .iOS)
            request.httpBody = try JSONEncoder().encode(payload)
            logger.i("logoutDevice payload encoded", tag: LOG_TAG)
        } catch {
            logger.e("Encoding payload failed in logoutDevice: \(error.localizedDescription)", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        let started = Date()
        session.dataTask(with: request) { data, response, error in
            let elapsedMs: Int = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("logoutDevice error in \(elapsedMs)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error)); return
            }
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("logoutDevice: No HTTP response in \(elapsedMs)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3))); return
            }
            
            let status: Int = http.statusCode
            let bytes: Int = data?.count ?? 0
            self.logger.i("← logoutDevice HTTP \(status), \(bytes) bytes, \(elapsedMs)ms", tag: self.LOG_TAG)
            
            let bodyString: String = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 {
                self.logger.i("logoutDevice success", tag: self.LOG_TAG)
                completion(.success(bodyString))
            } else {
                struct Problem: Decodable { let title: String?; let errors: [String:[String]]? }
                var message = "HTTP \(status)"
                if let data = data, let p = try? JSONDecoder().decode(Problem.self, from: data) {
                    message = p.errors?.values.first?.first ?? p.title ?? message
                } else if !bodyString.isEmpty {
                    message = bodyString
                }
                self.logger.w("logoutDevice failed [code=\(status)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: status,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
}
