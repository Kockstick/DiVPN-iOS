//
//  NetworkMonitor.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import Network
import SwiftUI

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let LOG_TAG = "NetworkMonitor"
    private let logger = DiLogger.shared
    
    func checkInternetAccess(completion: @escaping (Bool) -> Void) {
        logger.i("checkInternetAccess called", tag: LOG_TAG)
        
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            logger.e("Invalid URL", tag: LOG_TAG)
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                self.logger.i("Internet available", tag: self.LOG_TAG)
                completion(true)
            } else {
                if let error = error {
                    self.logger.w("Internet check failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                } else {
                    self.logger.w("Internet not available (no 200 response)", tag: self.LOG_TAG)
                }
                completion(false)
            }
        }.resume()
    }
}
