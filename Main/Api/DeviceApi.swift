//
//  DeviceApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import SwiftUI
import Foundation

class DeviceApi{
    let client: HTTPClient
    
    private let LOG_TAG: String = "DeviceApi"
    private let logger = DiLogger.shared
    
    init() {
        let baseUrl = URL(string: Bundle.main.baseUrl + "/Device")!
        let session = URLSession.shared
        
        self.client = HTTPClient(baseURL: baseUrl, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func loginDevice(_ user: User) async throws -> String {
        guard let device = DiStorage.loadDevice() ?? DeviceManager.GetDevice() else {
            throw APIError.encoding(NSError(domain: "Device",
                                            code: -10,
                                            userInfo: [NSLocalizedDescriptionKey: "No device info"]))
        }

        return try await client.sendText(
            "LoginDevice",
            method: .POST,
            json: device,
            accept: "text/plain,application/json"
        )
    }
    
    public func loginDevice(_ user: User, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("loginDevice called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("loginDevice success", tag: LOG_TAG)
                completion(.success(try await loginDevice(user)))
            }
            catch {
                logger.e("loginDevice failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func logoutDevice(_ user: User) async throws -> String {
        let payload = DeviceManager.GetDevice()

        let result = try await client.sendText(
            "LogoutDevice",
            method: .POST,
            json: payload,
            accept: "text/plain,application/json"
        )

        return result
    }

    public func logoutDevice(_ user: User, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("logoutDevice called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("logoutDevice success", tag: LOG_TAG)
                completion(.success(try await logoutDevice(user)))
            }
            catch {
                logger.e("logoutDevice failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
}
