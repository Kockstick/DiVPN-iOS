//
//  CodeViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 11.08.2025.
//

import SwiftUI

class CodeViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var timeToNewCode: Int = -1
    @Published var loadingTimeToNewCode: Bool = false
    
    private let LOG_TAG: String = "CodeViewModel"
    private let logger = DiLogger.shared
    
    private var verificationAttempts: Int = 0
    
    var verifErrorText: String?{
        switch verifError {
            case .IncorrectCode:
            return NSLocalizedString("invalid_verification_code", comment: "")
        case .TooManyAttempts:
            return NSLocalizedString("authentication_failed", comment: "")
        case .CodeExpired:
            return NSLocalizedString("code_expired", comment: "")
        default:
            return nil
        }
    }
    private var verifError: VerificationError?
    
    var timeToNewCodeText: String {
            if timeToNewCode <= 0 {
                return "..."
            } else {
                return "\(timeToNewCode)"
            }
        }
    
    private var timer: Timer?
    
    func verificate(code: String, completion: @escaping (Bool) -> Void){
        logger.i("verificate called", tag: LOG_TAG)
        loading = true
        
        guard let user = DiStorage.loadUser() else{
            logger.e("User not found in storage", tag: LOG_TAG)
            return
        }
        
        do{
            let hashCode = try HashGenerator.generateHash(salt: user.salt, input: code)
            logger.i("Hash generated", tag: LOG_TAG)
            
            let authApi = AuthApi()
            authApi.verificate(email: user.email, hashCode: hashCode){ result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let body):
                        if body.error != nil{
                            self.verifError = body.error
                            self.logger.w("Verification returned business error: \(String(describing: body.error))", tag: self.LOG_TAG)
                            self.loading = false
                            completion(false)
                            return
                        }
                        
                        self.logger.i("Verification success", tag: self.LOG_TAG)
                        
                        self.loading = false
                        completion(true)
                        break
                    case .failure(let error):
                        self.logger.e("Verification failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                        self.loading = false
                        completion(false)
                        break
                    }
                }
            }
        } catch{
            logger.e("Hash generation failed: \(error.localizedDescription)", tag: LOG_TAG)
        }
    }
    
    func getTimeToRequareNewCode(){
        logger.i("getTimeToRequareNewCode called", tag: LOG_TAG)
        guard let user = DiStorage.loadUser() else{
            logger.e("User not found in storage", tag: LOG_TAG)
            return
        }
        
        loadingTimeToNewCode = true
        
        let authApi = AuthApi()
        authApi.getTimeToRequareNewCode(email: user.email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let str):
                    self.loadingTimeToNewCode = false;
                    if let value = Int(str) {
                        self.logger.i("Time to new code received: \(value)s", tag: self.LOG_TAG)
                        self.timeToNewCode = value
                        self.сountdown(from: value)
                    } else {
                        self.logger.w("Failed to parse timeToNewCode from '\(str)'", tag: self.LOG_TAG)
                    }
                    break
                case .failure(let error):
                    self.loadingTimeToNewCode = false;
                    self.logger.e("getTimeToRequareNewCode failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    break
                }
            }
        }
    }
    
    func onButtonClick(){
        logger.i("onButtonClick called", tag: LOG_TAG)
        guard let user = DiStorage.loadUser() else{
            logger.e("[onButtonClick] User not found in storage", tag: LOG_TAG)
            return
        }
        
        loading = true
        timeToNewCode = -1;
        
        let authApi = AuthApi()
        authApi.sendVerificationCode(email: user.email){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.logger.i("sendVerificationCode success", tag: self.LOG_TAG)
                    self.loading = false
                    self.getTimeToRequareNewCode()
                    break
                case .failure(let error):
                    self.logger.e("sendVerificationCode failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    self.loading = false
                    break
                }
            }
        }
    }
    
    func сountdown(from seconds: Int? = nil) {
        if let seconds = seconds {
            timeToNewCode = seconds
            logger.i("Countdown started: \(seconds)s", tag: LOG_TAG)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeToNewCode > 0 {
                self.timeToNewCode -= 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.logger.i("Countdown finished", tag: self.LOG_TAG)
            }
        }
    }
}
