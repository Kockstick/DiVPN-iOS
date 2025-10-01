//
//  InvoiceApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 28.09.2025.
//

import Foundation
import SwiftUI

class InvoiceApi{
    let client: HTTPClient
    
    private let LOG_TAG = "AuthApi"
    private let logger = DiLogger.shared
    
    init() {
        let baseUrl = URL(string: Bundle.main.baseUrl + "/Invoice")!
        let session = URLSession.shared
        
        self.client = HTTPClient(baseURL: baseUrl, session: session, tokenProvider: DiTokenProvider.shared)
    }
    
    func getInvoiceUrl() async throws -> String {
        try await client.sendText("GetInvoiceUrl", method: .GET, accept: "application/json")
    }
    
    public func getInvoiceUrl(completion: @escaping (Result<String, Error>) -> Void){
        logger.i("getInvoiceUrl called", tag: LOG_TAG)
        Task {
            do {
                let res = try await getInvoiceUrl()
                logger.i("getInvoiceUrl success", tag: LOG_TAG)
                completion(.success(res))
            }
            catch {
                logger.e("getInvoiceUrl failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    public func getSubscribtionStatus() async throws -> StatusSubscribtion{
        let (data, http) = try await client.sendData("GetAgreementStatus", method: .GET, accept: "application/json")
        let resp = try JSONDecoder().decode(SubscribtionStatusModel.self, from: data)
        return resp.status
    }
    
    public func getSubscribtionStatus(completion: @escaping (Result<StatusSubscribtion, Error>) -> Void){
        logger.i("getSubscribtionStatus called", tag: LOG_TAG)
        Task {
            do {
                let res = try await getSubscribtionStatus()
                logger.i("getSubscribtionStatus success", tag: LOG_TAG)
                completion(.success(res))
            }
            catch {
                logger.e("getSubscribtionStatus failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    public func getSubscribtionPrice() async throws -> PriceModel{
        let (data, http) = try await client.sendData("GetSubscribtionPrice", method: .GET, accept: "application/json")
        let resp = try JSONDecoder().decode(PriceModel.self, from: data)
        return resp
    }
    
    public func getSubscribtionPrice(completion: @escaping (Result<PriceModel, Error>) -> Void){
        logger.i("getSubscribtionPrice called", tag: LOG_TAG)
        Task {
            do {
                let res = try await getSubscribtionPrice()
                logger.i("getSubscribtionPrice success", tag: LOG_TAG)
                DispatchQueue.main.async {
                    completion(.success(res))
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.logger.e("getSubscribtionPrice failed", tag: self.LOG_TAG)
                    completion(.failure(error))
                }
            }
        }
    }
}
