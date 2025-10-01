//
//  ShopViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 19.08.2025.
//

import SwiftUI

class ShopViewModel: ObservableObject {
    private let LOG_TAG = "ShopViewModel"
    private let logger = DiLogger.shared
    
    func getInvoiceUrl() async throws -> String {
        let api = InvoiceApi()
        
        do{
            let url = try await api.getInvoiceUrl()
            return url.unquoted
        } catch{
            self.logger.e("Error get invoice url: \(error)", tag: self.LOG_TAG)
            throw error
        }
    }
}
