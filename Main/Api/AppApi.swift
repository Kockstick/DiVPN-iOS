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
    
    private let session = URLSession.shared
    
    init() {
        let base = URL(string: Bundle.main.baseUrl + "/App")!
        let session = URLSession.shared
        self.client = HTTPClient(baseURL: base, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func getLastSupportVersion() async throws -> AppVersionModel {
        let (data, _) = try await client.sendData(
            "GetLastSupportVersion",
            method: .GET,
            accept: "application/json"
        )

        return try JSONDecoder().decode(AppVersionModel.self, from: data)
    }
    
    public func getLastSupportVersion(completion: @escaping (Result<AppVersionModel, Error>) -> Void){
        logger.i("getLastSupportVersion called", tag: LOG_TAG)
        Task {
            do {
                let res = try await getLastSupportVersion()
                logger.i("getLastSupportVersion success", tag: LOG_TAG)
                completion(.success(res))
            }
            catch {
                logger.e("getLastSupportVersion failed", tag: LOG_TAG)
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
