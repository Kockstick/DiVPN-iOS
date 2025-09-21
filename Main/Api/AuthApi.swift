//
//  VerificationApi.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import SwiftUI
import Foundation

class AuthApi {
    let baseUrl: String
    
    private let LOG_TAG = "AuthApi"
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
        self.baseUrl = Bundle.main.baseUrl + "/Auth"
    }
    
    public func sendVerificationCode(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        logger.i("sendVerificationCode started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/GetVerifCode") else {
            logger.e("Invalid URL in sendVerificationCode", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1))); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        
        let payload = EmailModel(email: email)
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            logger.e("Encoding payload failed in sendVerificationCode", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                 self.logger.e("sendVerificationCode error: \(error.localizedDescription)", tag: self.LOG_TAG)
                 completion(.failure(error)); return
             }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("sendVerificationCode: No HTTP response", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3))); return
            }
            
            self.logger.i("sendVerificationCode response code: \(http.statusCode)", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 || http.statusCode == 460 {
                if let data = data {
                    do {
                        let user: User = try DiDecoder.getJson2UserDecoder().decode(User.self, from: data)
                        DiStorage.saveUser(user: user)
                        DiStorage.saveRefCode(code: user.referralCode)
                        self.logger.i("User saved in sendVerificationCode", tag: self.LOG_TAG)
                    } catch {
                        self.logger.w("User decode failed in sendVerificationCode", tag: self.LOG_TAG)
                    }
                }
                completion(.success(bodyString))
            } else {
                self.logger.w("sendVerificationCode failed with HTTP \(http.statusCode)", tag: self.LOG_TAG)
                struct Problem: Decodable { let title: String?; let errors: [String:[String]]? }
                var message = "HTTP \(http.statusCode)"
                if let data = data, let p = try? JSONDecoder().decode(Problem.self, from: data) {
                    message = p.errors?.values.first?.first ?? p.title ?? message
                } else if !bodyString.isEmpty {
                    message = bodyString
                }
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    public func verificate(email: String, hashCode: String, completion: @escaping (Result<VerificationResult, Error>) -> Void){
        logger.i("verificate started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/Verificate") else {
            logger.e("Invalid URL in verificate", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1))); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        
        let device = DeviceManager.GetDevice()
        let payload = VerificateModel(email: email, hashCode: hashCode, device: device!)
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            logger.e("Encoding payload failed in verificate", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        session.dataTask(with: request){ data, response, error in
            if let error = error {
                self.logger.e("verificate error: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("verificate: No HTTP response", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            self.logger.i("verificate response code: \(http.statusCode)", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if let data = data {
                do {
                    let verifResult: VerificationResult = try DiDecoder.getJson2VerificationResultDecoder().decode(VerificationResult.self, from: data)
                    
                    if http.statusCode == 200{
                        DiStorage.saveToken(token: verifResult.token!)
                        self.logger.i("Verification success, token saved", tag: self.LOG_TAG)
                        
                        if !bodyString.isEmpty {
                            TariffManager.shared.loadTariff { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        self.logger.i("Tariff loaded in verificate", tag: self.LOG_TAG)
                                    case .failure(let error):
                                        self.logger.w("Tariff load error in verificate: \(error.localizedDescription)", tag: self.LOG_TAG)
                                    }
                                }
                            }
                        }
                    }
                    
                    completion(.success(verifResult))
                    return
                }
                catch {
                    self.logger.e("VerificationResult decode failed in verificate", tag: self.LOG_TAG)
                }
            }
            else{
                self.logger.e("verificate empty body", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "ParseError", code: -4,
                                            userInfo: [NSLocalizedDescriptionKey: "Empty body, no token header"])))
            }
        }.resume()
    }
    
    public func checkAuth(completion: @escaping (Result<String, Error>) -> Void){
        logger.i("checkAuth started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/CheckAuth") else {
            logger.e("Invalid URL in checkAuth", tag: LOG_TAG)
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
            logger.i("Token attached in checkAuth", tag: LOG_TAG)
        } else {
            logger.w("No token found in checkAuth", tag: LOG_TAG)
        }
        
        let payload = DeviceManager.GetDevice()
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            logger.e("Encoding payload failed in checkAuth", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        request.timeoutInterval = 20
        
        session.dataTask(with: request){ data, response, error in
            if let error = error {
                self.logger.e("checkAuth error: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("checkAuth: No HTTP response", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3)))
                return
            }
            
            self.logger.i("checkAuth response code: \(http.statusCode)", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 {
                completion(.success(bodyString))
                return
            } else {
                self.logger.w("checkAuth failed with HTTP \(http.statusCode)", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: bodyString.isEmpty ? "No authorized" : bodyString])))
            }
        }.resume()
    }
    
    public func getTimeToRequareNewCode(email: String, completion: @escaping (Result<String, Error>) -> Void){
        logger.i("getTimeToRequareNewCode started", tag: LOG_TAG)
        
        guard let url = URL(string: "\(baseUrl)/GetTimeToRequareNewCode") else {
            logger.e("Invalid URL in getTimeToRequareNewCode", tag: LOG_TAG)
            completion(.failure(NSError(domain: "InvalidURL", code: -1))); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        
        let payload = EmailModel(email: email)
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            logger.e("Encoding payload failed in getTimeToRequareNewCode", tag: LOG_TAG)
            completion(.failure(error)); return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logger.e("getTimeToRequareNewCode error: \(error.localizedDescription)", tag: self.LOG_TAG)
                completion(.failure(error));
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                self.logger.e("getTimeToRequareNewCode: No HTTP response", tag: self.LOG_TAG)
                completion(.failure(NSError(domain: "NoHTTPResponse", code: -3))); return
            }
            
            self.logger.i("getTimeToRequareNewCode response code: \(http.statusCode)", tag: self.LOG_TAG)
            
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            if http.statusCode == 200 {
                completion(.success(bodyString))
            } else {
                self.logger.w("getTimeToRequareNewCode failed with HTTP \(http.statusCode)", tag: self.LOG_TAG)
                struct Problem: Decodable { let title: String?; let errors: [String:[String]]? }
                var message = "HTTP \(http.statusCode)"
                if let data = data, let p = try? JSONDecoder().decode(Problem.self, from: data) {
                    message = p.errors?.values.first?.first ?? p.title ?? message
                } else if !bodyString.isEmpty {
                    message = bodyString
                }
                completion(.failure(NSError(domain: "HTTPError",
                                            code: http.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
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
