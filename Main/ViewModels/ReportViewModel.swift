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
    
    func sendBugReport() async -> Bool {
        do{
            let s = try await api.sendBugReportAsync(text: text)
            return true
        } catch {
            return false
        }
    }
}
