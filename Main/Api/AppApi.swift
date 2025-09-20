//
//  AppApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 24.08.2025.
//

import SwiftUI
import Foundation

class AppApi {
    let baseUrl: String
    
    private let LOG_TAG: String = "AppApi"
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
        self.baseUrl = Bundle.main.baseUrl + "/App"
    }
    
    public func checkUpdate(_ appVersion: AppVersionModel, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("checkUpdate started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/IsActualVersion") else {
            logger.e("Invalid URL in checkUpdate", tag: LOG_TAG)
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
            logger.i("Token attached for checkUpdate", tag: LOG_TAG)
        } else {
            logger.w("No token available for checkUpdate", tag: LOG_TAG)
        }
        
        request.timeoutInterval = 20
        
        do {
            let payload = appVersion
            request.httpBody = try JSONEncoder().encode(payload)
            logger.i("Payload encoded for checkUpdate", tag: LOG_TAG)
        } catch {
            logger.e("Encoding payload failed in checkUpdate: \(error.localizedDescription)", tag: LOG_TAG)
            completion(.failure(error));
            return
        }
        
        let started = Date()
        session.dataTask(with: request) { data, response, error in
            let elapsedMs: Int = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("checkUpdate error in \(elapsedMs)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error))
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("checkUpdate: No HTTP response in \(elapsedMs)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3))); return
            }
            
            let status: Int = http.statusCode
            let bytes: Int = data?.count ?? 0
            self.logger.i("← checkUpdate HTTP \(status), \(bytes) bytes, \(elapsedMs)ms", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let trimmed: String = bodyString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if http.statusCode == 200 {
                completion(.success(bodyString))
            } else {
                let message: String = trimmed.isEmpty ? "Update check failed" : trimmed
                self.logger.w("checkUpdate failed [code=\(status)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: status,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func sendBugReport(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("sendBugReport started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/BugReport") else {
            logger.e("Invalid URL in sendBugReport", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }
        
        guard let fileURL = DiLogger.shared.snapshotURL() else {
            logger.e("Log file not available in sendBugReport", tag: LOG_TAG)
            completion(.failure(NSError(domain: "DiLogger", code: -10,
                                        userInfo: [NSLocalizedDescriptionKey: "Log file not available"])))
            return
        }
        
        let hashDevice = (DiStorage.loadDevice()?.hashSerialNumber ?? "").unquoted
        let serverId = DiStorage.loadServer()?.id ?? 0
        if hashDevice.isEmpty { logger.w("hashDevice is empty in sendBugReport", tag: LOG_TAG) }
        logger.i("sendBugReport context: serverId=\(serverId)", tag: LOG_TAG)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let form = BugReportForm(text: text, fileURL: fileURL, hashDevice: hashDevice, serverId: serverId)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if var token = DiStorage.loadToken(), !token.isEmpty {
            token = token.unquoted
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.i("Token attached for sendBugReport", tag: LOG_TAG)
        } else {
            logger.w("No token available for sendBugReport", tag: LOG_TAG)
        }

        do {
            let body = try form.buildMultipartBody(boundary: boundary)
            request.httpBody = body
            request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
        } catch {
            logger.e("Failed to build multipart body in sendBugReport: \(error.localizedDescription)", tag: LOG_TAG)
            completion(.failure(error))
            return
        }
        
        let started = Date()
        session.dataTask(with: request) { data, response, error in
            let elapsedMs = Int(Date().timeIntervalSince(started) * 1000)
            
            if let error = error {
                self.logger.e("sendBugReport error in \(elapsedMs)ms: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error))
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("sendBugReport: No HTTP response in \(elapsedMs)ms", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            let status = http.statusCode
            let bytes = data?.count ?? 0
            self.logger.i("← sendBugReport HTTP \(status), \(bytes) bytes, \(elapsedMs)ms", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let trimmed = bodyString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            try? FileManager.default.removeItem(at: fileURL)
            
            if status == 200 {
                completion(.success(trimmed.isEmpty ? "Success" : trimmed))
            } else {
                let message = trimmed.isEmpty ? "BugReport failed" : trimmed
                self.logger.w("sendBugReport failed [code=\(status)]", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: status,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func sendBugReportAsync(text: String) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            self.sendBugReport(text: text) { result in
                switch result {
                case .success(let s): cont.resume(returning: s)
                case .failure(let e): cont.resume(throwing: e)
                }
            }
        }
    }
}
