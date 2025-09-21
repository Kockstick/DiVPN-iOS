//
//  EmailViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 08.08.2025.
//
import SwiftUI

class EmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var loading: Bool = false
    @Published var errMessage: String?
    
    private let LOG_TAG: String = "EmailViewModel"
    private let logger = DiLogger.shared
    
    func onButtonClick(_ completion: @escaping (Bool) -> Void){
        logger.i("onButtonClick called", tag: LOG_TAG)
        
        var isValidEmail: Bool = validateEmail(email)
        if !isValidEmail {
            logger.w("Invalid email format", tag: LOG_TAG)
            errMessage = "Неверный формат email"
            completion(false)
            return
        } else{
            errMessage = nil
        }
        
        loading = true
        logger.i("Requesting verification code", tag: LOG_TAG)
        let authApi = AuthApi()
        authApi.sendVerificationCode(email){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.logger.i("sendVerificationCode success", tag: self.LOG_TAG)
                    self.loading = false
                    completion(true)
                    break
                case .failure(let error):
                    self.logger.e("sendVerificationCode failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    self.loading = false
                    completion(false)
                    break
                }
            }
        }
    }
    
    func checkExistUser(){
        if let user = DiStorage.loadUser() {
            self.email = user.email
            logger.i("Prefilled email from storage", tag: LOG_TAG)
        } else {
            logger.w("No user in storage to prefill email", tag: LOG_TAG)
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex.firstMatch(in: email, options: [], range: range) != nil
    }
}
