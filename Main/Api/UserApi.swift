//
//  UserApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 17.08.2025.
//

import SwiftUI
import Foundation

class UserApi {
    let client: HTTPClient
    
    private let LOG_TAG = "UserApi"
    private let logger = DiLogger.shared
    
    init() {
        let baseUrl = URL(string: Bundle.main.baseUrl + "/User")!
        
#if DEBUG
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        let session = URLSession(configuration: cfg,delegate: InsecureSessionDelegate(),delegateQueue: nil)
#else
        let session = URLSession.shared
#endif
        
        self.client = HTTPClient(baseURL: baseUrl, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func getSsKey() async throws -> String {
        let raw = try await client.sendText(
            "GetSSKey",
            method: .GET,
            accept: "text/plain,application/json"
        )
        return raw.unquoted
    }

    public func getSsKey(completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("getSsKey called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("getSsKey success", tag: LOG_TAG)
                completion(.success(try await getSsKey()))
            }
            catch {
                logger.e("getSsKey failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }

    func getTariff() async throws -> CurrentTariffModel {
        let (data, _) = try await client.sendData(
            "GetTariff",
            method: .GET,
            accept: "application/json"
        )

        return try DiDecoder.getJson2TariffDecoder()
            .decode(CurrentTariffModel.self, from: data)
    }

    public func getTariff(completion: @escaping (Result<CurrentTariffModel, Error>) -> Void) {
        logger.i("getTariff called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("getTariff success", tag: LOG_TAG)
                completion(.success(try await getTariff()))
            }
            catch {
                logger.e("getTariff failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }

    func useReferral(code: String) async throws -> Bool {
        logger.i("Use referral started", tag: LOG_TAG)

        let payload = ReferralCodeModel(code: code)

        let soft = Set(Array(400...499))
        let (data, http) = try await client.sendData(
            "UseReferral",
            method: .POST,
            json: payload,
            accept: "application/json,text/plain",
            acceptStatuses: soft.union([200])
        )

        if http.statusCode == 200 {
            ReferralManager.shared.isReferralUsed = true
            logger.i("Referral success", tag: LOG_TAG)
            TariffManager.shared.updateTariff()
            return true
        }

        if let body = String(data: data, encoding: .utf8), !body.isEmpty {
            logger.w("Referral rejected [\(http.statusCode)]: \(body)", tag: LOG_TAG)
        } else {
            logger.w("Referral rejected [\(http.statusCode)]", tag: LOG_TAG)
        }

        return false
    }

    public func useReferral(code: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        logger.i("useReferral called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("useReferral success", tag: LOG_TAG)
                completion(.success(try await useReferral(code: code)))
            }
            catch {
                logger.e("useReferral failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }

}
