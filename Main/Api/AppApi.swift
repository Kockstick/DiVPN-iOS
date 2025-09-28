//
//  AppApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 24.08.2025.
//

import SwiftUI
import Foundation

class AppApi {
    let client: HTTPClient
    
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
        let base = URL(string: Bundle.main.baseUrl + "/App")!
#if DEBUG
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        let session = URLSession(configuration: cfg, delegate: InsecureSessionDelegate(), delegateQueue: nil)
#else
        let session = URLSession.shared
#endif
        self.client = HTTPClient(baseURL: base, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func checkUpdate(_ appVersion: AppVersionModel) async throws -> String {
        try await client.sendText("IsActualVersion", method: .POST, json: appVersion, accept: "application/json")
    }
    
    public func checkUpdate(_ appVersion: AppVersionModel, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("checkUpdate called", tag: LOG_TAG)
        Task {
            do {
                let res = try await checkUpdate(appVersion)
                logger.i("checkUpdate success", tag: LOG_TAG)
                completion(.success(res))
            }
            catch {
                logger.e("checkUpdate failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func sendBugReport(text: String) async throws -> String {
        guard let fileURL = DiLogger.shared.snapshotURL() else {
            throw NSError(domain: "DiLogger", code: -10,
                          userInfo: [NSLocalizedDescriptionKey: "Log file not available"])
        }
        
        let hashDevice = (DeviceManager.GetHash()).unquoted
        let serverId = DiStorage.loadServer()?.id ?? 0

        let boundary = "Boundary-\(UUID().uuidString)"
        let form = BugReportForm(text: text, fileURL: fileURL, hashDevice: hashDevice, serverId: serverId)
        let body = try form.buildMultipartBody(boundary: boundary)
        let contentType = "multipart/form-data; boundary=\(boundary)"

        defer { try? FileManager.default.removeItem(at: fileURL) }
        return try await client.sendMultipart("BugReport", method: .POST, body: body, contentType: contentType)
    }
    
    func sendBugReport(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("sendBugReport called", tag: LOG_TAG)
        Task {
            do {
                logger.i("sendBugReport success", tag: LOG_TAG)
                completion(.success(try await sendBugReport(text: text)))
            }
            catch {
                logger.e("sendBugReport failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
}
