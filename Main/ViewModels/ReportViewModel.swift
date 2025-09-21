//
//  ReportViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 31.08.2025.
//

import SwiftUI

class ReportViewModel: ObservableObject{
    @Published var text: String = ""
    
    private let api = AppApi()
    
    private let LOG_TAG = "ReportViewModel"
    private let logger = DiLogger.shared
    
    func sendBugReport() async -> Bool {
        logger.i("sendBugReport started with text length: \(text.count)", tag: LOG_TAG)
        
        do{
            let s = try await api.sendBugReport(text: text)
            logger.i("sendBugReport success", tag: LOG_TAG)
            return true
        } catch {
            logger.e("sendBugReport failed: \(error.localizedDescription)", tag: LOG_TAG)
            return false
        }
    }
}
