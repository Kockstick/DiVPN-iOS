//
//  AddServerViewModel.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 25.02.2026.
//

import SwiftUI

class AddServerViewModel: ObservableObject{
    @Published var name: String = "My server"
    @Published var apiKey: String = ""
    
    var isApiError: Bool {
        apiKey != "" && !isApiValid
    }
    
    var isFormValid: Bool {
        isNameValid && isApiValid
    }

    var isNameValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 1
    }

    var isApiValid: Bool {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = trimmed.range(of: "https://") else { return false }
        let urlString = String(trimmed[range.lowerBound...])
        guard let url = URL(string: urlString),
              url.scheme == "https",
              url.host != nil,
              !url.path.isEmpty else { return false }
        return true
    }
    
    func addServer(_ name: String, _ api: String) -> OutlineServerApi{
        let server = OutlineServerApi(id: UUID(), name: name, apiUrl: api)
        OutlineServersManager.shared.add(server)
        return server;
    }
}
