//
//  VerificationApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI
import Foundation

class AuthApi {
    let client: HTTPClient
    
    private let LOG_TAG = "AuthApi"
    private let logger = DiLogger.shared
    
    private static var isRefreshingToken: Bool = false
    
    
    init() {
        let baseUrl = URL(string: Bundle.main.baseUrl + "/Auth")!
        let session = URLSession.shared
        
        self.client = HTTPClient(baseURL: baseUrl, session: session)
    }
    
    func sendVerificationCode(_ email: String) async throws -> String {
        if(!AgreementManager.shared.isPrivacyPolicyAccept){
            throw APIError.encoding(NSError(domain: "AuthApi", code: -10, userInfo: [NSLocalizedDescriptionKey : "Error: Privacy policy not accept"]))
        }
        var agreement = AgreementModel(typeDevice: TypeDevice.iOS, typeAgreement: TypeAgreement.PrivacyPolicy)
        var getVerifCodeModel = GetVerifCodeModel(emailModel: EmailModel(email: email), agreementModel: agreement)
        let payload = getVerifCodeModel
        
        let (data, http) = try await client.sendData(
            "GetVerifCode",
            method: .POST,
            json: payload,
            accept: "application/json",
            acceptStatuses: [460]
        )
        
        if !data.isEmpty {
            if let user = try? DiDecoder.getJson2UserDecoder().decode(User.self, from: data) {
                DiStorage.saveUser(user: user)
                DiStorage.saveRefCode(code: user.referralCode)
                logger.i("User saved in sendVerificationCode", tag: LOG_TAG)
            }
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func sendVerificationCode(_ email: String, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("sendVerificationCode called", tag: LOG_TAG)
        Task {
            do {
                logger.i("sendVerificationCode success", tag: LOG_TAG)
                completion(.success(try await sendVerificationCode(email)))
            }
            catch {
                logger.e("sendVerificationCode failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    public func verificate(email: String, hashCode: String) async throws -> VerificationResult{
        logger.i("verificate started", tag: LOG_TAG)
        
        guard let device = DeviceManager.GetDevice() else {
            throw APIError.encoding(NSError(domain: "Device", code: -10,
                                            userInfo: [NSLocalizedDescriptionKey: "No device info"]))
        }
        
        let payload = VerificateModel(email: email, hashCode: hashCode, device: device)
        
        let (data, http) = try await client.sendData(
            "Verificate",
            method: .POST,
            json: payload,
            accept: "application/json",
            acceptStatuses: [422]
        )
        
        let resp = try DiDecoder.getJson2VerificationResultDecoder().decode(VerificationResult.self, from: data)
        
        if http.statusCode == 200 {
            if let tokenResult = resp.tokenResult, let refresh = tokenResult.refresh {
                do{
                    try DiStorage.saveToken(token: tokenResult)
                    logger.i("Verification success, tokens saved", tag: LOG_TAG)
                } catch{
                    logger.e("Verificate error: \(error)", tag: LOG_TAG)
                }
            } else {
                logger.w("200 but no tokens in response", tag: LOG_TAG)
            }
            
            TariffManager.shared.loadTariff { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success: self.logger.i("Tariff loaded in verificate", tag: self.LOG_TAG)
                    case .failure(let e): self.logger.w("Tariff load error: \(e.localizedDescription)", tag: self.LOG_TAG)
                    }
                }
            }
            
            return resp
        }
        
        if http.statusCode == 422 {
            return resp
        }
        
        throw APIError.http(http.statusCode, message: nil, url: nil, body: String(data: data, encoding: .utf8))
    }
    
    func verificate(email: String, hashCode: String, completion: @escaping (Result<VerificationResult, Error>) -> Void){
        logger.i("verificate called", tag: LOG_TAG)
        Task {
            do {
                logger.i("verificate success", tag: LOG_TAG)
                completion(.success(try await verificate(email: email, hashCode: hashCode)))
            }
            catch {
                logger.e("verificate failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func refresh(_ refresh: String, retryCount: Int = 0) async throws -> TokenResult?{
        if(Self.isRefreshingToken){
            logger.i("Token is refreshing", tag: LOG_TAG)
            return nil
        }
        
        logger.i("Refresh token started", tag: LOG_TAG)
        Self.isRefreshingToken = true
        defer {
            Self.isRefreshingToken = false
        }
        
        let payload = RefreshTokenModel(refreshToken: refresh)
        
        do{
            let (data, http) = try await client.sendData(
                "Refresh",
                method: .POST,
                json: payload,
                accept: "application/json"
            )
            
            
            let resp = try? DiDecoder.getJson2TokenDecoder().decode(TokenResult.self, from: data)
            
            switch http.statusCode {
                
            case 200 ..< 300:
                if let tokenResult = resp, let refresh = tokenResult.refresh  {
                    try? DiStorage.saveToken(token: tokenResult)
                    logger.i("Refresh token success, tokens saved", tag: LOG_TAG)
                } else {
                    logger.w("200 but no tokens in response", tag: LOG_TAG)
                }
                return resp
                
            case 460:
                logger.i("Token alrady is refreshing", tag: LOG_TAG)
                return resp
            default:
                logger.w("Token not refreshed. Status code: \(http.statusCode)")
            }
            
            throw APIError.http(http.statusCode, message: nil, url: nil, body: String(data: data, encoding: .utf8))
        }
        catch let APIError.http(code, message, _, body){
            do {
                logger.i("ERROR CODE - \(code)", tag: LOG_TAG)
                switch code {
                case -1001, -1009, -1005:
                    
                    if retryCount > 2 { throw APIError.http(code, message: message, url: nil, body: body) }
                    let rCount = retryCount + 1;
                    logger.i("refresh retry - \(rCount)", tag: LOG_TAG)
                    return try await self.refresh(refresh, retryCount: rCount)
                case 401:
                    logger.i("Token is incorrect, logout", tag: LOG_TAG)
                    DiStorage.clearToken()
                    DiStorage.clearServer()
                    AuthState.shared.isAuthorized = false
                default:
                    logger.e("Non-retry URL error", tag: LOG_TAG)
                }
                throw APIError.http(code, message: message, url: nil, body: body)
            }
            catch {
                logger.e("Error refresh token", tag: LOG_TAG)
                throw error
            }
        }
    }
    
    func refresh(_ refresh: String, completion: @escaping (Result<TokenResult?, Error>) -> Void){
        logger.i("refresh called", tag: LOG_TAG)
        Task {
            do {
                logger.i("refresh success", tag: LOG_TAG)
                completion(.success(try await self.refresh(refresh)))
            }
            catch {
                logger.e("refresh failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func checkAuth() async throws -> Bool {
        guard let token = try? await DiTokenProvider.shared.GetAccessToken() else {
            throw APIError.encoding(NSError(domain: "Token",
                                            code: -10,
                                            userInfo: [NSLocalizedDescriptionKey: "No token"]))
        }
        
        guard let device = DeviceManager.GetDevice() else {
            throw APIError.encoding(NSError(domain: "Device",
                                            code: -10,
                                            userInfo: [NSLocalizedDescriptionKey: "No device info"]))
        }
        
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(token)"
        
        let (data, http) = try await client.sendData(
            "CheckAuth",
            method: .POST,
            headers: headers,
            json: device,
            accept: "text/plain,application/json"
        )
        
        if http.statusCode == 401 {
            return false
        }
        
        return true
    }
    
    public func checkAuth(completion: @escaping (Result<Bool, Error>) -> Void) {
        logger.i("checkAuth called", tag: LOG_TAG)
        Task {
            do{
                logger.i("checkAuth success", tag: LOG_TAG)
                completion(.success(try await checkAuth()))
            }
            catch {
                logger.e("checkAuth failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
    
    func getTimeToRequareNewCode(email: String) async throws -> String {
        let payload = EmailModel(email: email)
        
        // сервер иногда может вернуть text/plain или json — примем оба
        return try await client.sendText(
            "GetTimeToRequareNewCode",
            method: .POST,
            json: payload,
            accept: "text/plain,application/json"
        )
    }
    
    public func getTimeToRequareNewCode(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("getTimeToRequareNewCode called", tag: LOG_TAG)
        Task {
            do   {
                logger.i("getTimeToRequareNewCode success", tag: LOG_TAG)
                completion(.success(try await getTimeToRequareNewCode(email: email)))
            }
            catch {
                logger.e("getTimeToRequareNewCode failed", tag: LOG_TAG)
                completion(.failure(error))
            }
        }
    }
}

extension String {
    var unquoted: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}

#if DEBUG
final class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    // Разрешаем только наш локальный хост/IP
    private let allowedHosts: Set<String> = ["192.168.0.107"]
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Подстраховка: принимаем только наш адрес
        guard allowedHosts.contains(challenge.protectionSpace.host) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // ⚠️ DEBUG-хак: доверяем присланному сертификату как есть
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
#endif
